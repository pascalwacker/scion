@0x8f4bd412642c9517;
using Go = import "go.capnp";
$Go.package("proto");
$Go.import("github.com/scionproto/scion/go/proto");

using Common = import "common.capnp";
using Sign = import "sign.capnp";
using PSeg = import "path_seg.capnp";
using PathMgmt = import "path_mgmt.capnp";

struct SCIONDMsg {
    id @0 :UInt64;  # Request ID
    union {
        unset @1 :Void;
        pathReq @2 :PathReq;
        pathReply @3 :PathReply;
        asInfoReq @4 :ASInfoReq;
        asInfoReply @5 :ASInfoReply;
        revNotification @6 :RevNotification;
        ifInfoRequest @7 :IFInfoRequest;
        ifInfoReply @8 :IFInfoReply;
        serviceInfoRequest @9 :ServiceInfoRequest;
        serviceInfoReply @10 :ServiceInfoReply;
        revReply @11 :RevReply;
        segTypeHopReq @12 :SegTypeHopReq;
        segTypeHopReply @13 :SegTypeHopReply;
    }
    traceId @14 :Data;
}

struct PathReq {
    dst @0 :UInt64;  # Destination ISD-AS
    src @1 :UInt64;  # Source ISD-AS
    maxPaths @2: UInt16;  # Maximum number of paths requested
    flags :group {
        refresh @3 :Bool; # Fetch segments again for dst.
        hidden @4 :Bool; # Request hidden segments
    }
    hpCfgs @5 :List(PathMgmt.HPGroupId);
}

struct PathReply {
    errorCode @0 :UInt16;
    entries @1 :List(PathReplyEntry);
}

struct PathReplyEntry {
    path @0 :FwdPathMeta;  # End2end path
    hostInfo @1 :HostInfo;  # First hop host info.
    pathStaticInfo @2 :PathMetadata; # Static info describing the path
}

struct HostInfo {
    port @0 :UInt16;  # Reachable port of the host.
    addrs :group {  # Addresses of the host.
        ipv4 @1 :Data;
        ipv6 @2 :Data;
    }
}

struct PathMetadata {
    totalLatency @0 :UInt16;
    totalHops @1 :UInt8;
    minimalBandwidth @2 :UInt32;
    linkTypes @3 :List(InterfaceLinkType);
    asLocations @4 :List(Geo);
    notes @5: List(Note);

    struct InterfaceLinkType {
        interLinkType @0 :UInt16;
        peerLinkType @1 :UInt16;
        isdas @2 :UInt64;
    }

    struct Geo {
        routerLocations @0 :List(GPSData);
        isdas @1 :UInt64;

        struct GPSData {
            latitude @0 :Float32;
            longitude @1 :Float32;
            address @2 :Text;
        }
    }

    struct Note {
        note @0 :Text;
        isdas @1 :UInt64;
    }
}

struct FwdPathMeta {
    fwdPath @0 :Data;  # The info- and hopfields of the path
    mtu @1 :UInt16;
    interfaces @2 :List(PathInterface);
    expTime @3 :UInt32; # expiration time in seconds since epoch.
}

struct PathInterface {
    isdas @0 :UInt64;
    ifID @1 :UInt64;
}

struct ASInfoReq {
    isdas @0 :UInt64;  # The AS ID for which the AS Info is requested. If unset, returns info about the local AS(es).
}

struct ASInfoReply {
    entries @0 :List(ASInfoReplyEntry);  # List of ASes the host is part of. First entry is the default AS.
}

struct ASInfoReplyEntry {
    isdas @0 :UInt64;
    mtu @1 :UInt16;  # The MTU of the AS.
    isCore @2 :Bool;  # True, if this is a core AS.
}

struct RevNotification {
    sRevInfo @0 :Sign.SignedBlob;
}

struct RevReply {
    result @0 :UInt16;
}

struct IFInfoRequest {
    ifIDs @0 :List(UInt64);  # The if IDs for which a client requests the host infos. Empty list means all interfaces of the local AS.
}

struct IFInfoReply {
    entries @0 :List(IFInfoReplyEntry);
}

struct IFInfoReplyEntry {
    ifID @0 :UInt64;  # The ID of the interface.
    hostInfo @1 :HostInfo;  # The host info of the internal address of the interface.
}

struct ServiceInfoRequest {
    serviceTypes @0 :List(Common.ServiceType);  # The service types for which a client requests the host infos. Empty list means all service types.
}

struct ServiceInfoReply {
    entries @0 :List(ServiceInfoReplyEntry);
}

struct ServiceInfoReplyEntry {
    serviceType @0 :Common.ServiceType;  # The service ID of the service.
    ttl @1 :UInt32;  # The TTL for the service record in seconds (currently unused).
    hostInfos @2 :List(HostInfo);  # The host infos of the service.
}

struct SegTypeHopReq {
    type @0 :PSeg.PathSegType;  # The path segments type: up, down, core.
}

struct SegTypeHopReply {
    entries @0 :List(SegTypeHopReplyEntry);  # List of path segments matching type request, if any
}

struct SegTypeHopReplyEntry {
    interfaces @0 :List(PathInterface);  # List of interfaces for the segment
    timestamp @1 :UInt32;                # Creation timestamp, seconds since Unix Epoch
    expTime @2 :UInt32;                  # Expiration timestamp, seconds since Unix Epoch
}
