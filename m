Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id C61808E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:21:59 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id p66so7978456itc.0
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 13:21:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m200sor11943909itb.0.2018.12.19.13.21.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 13:21:59 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com> <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
 <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com> <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
 <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
In-Reply-To: <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 20 Dec 2018 02:21:47 +0500
Message-ID: <CABXGCsMygWFqnkaZbpLEBd9aBkk9=-fRnDMNOnkRfPZaeheoCg@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Content-Type: multipart/mixed; boundary="000000000000aba022057d669a4b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "StDenis, Tom" <Tom.StDenis@amd.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

--000000000000aba022057d669a4b
Content-Type: text/plain; charset="UTF-8"

I see that backtrace in my previous message are borked.
I place backtrace in text file for more comfort reading in this message.


--
Best Regards,
Mike Gavrilov.

--000000000000aba022057d669a4b
Content-Type: text/plain; charset="US-ASCII"; name="umr-backtrace.txt"
Content-Disposition: attachment; filename="umr-backtrace.txt"
Content-Transfer-Encoding: base64
Content-ID: <f_jpvomu480>
X-Attachment-Id: f_jpvomu480

Q2Fubm90IHNlZWsgdG8gTU1JTyBhZGRyZXNzOiBCYWQgZmlsZSBkZXNjcmlwdG9yCltFUlJPUl06
IENvdWxkIG5vdCBvcGVuIHJpbmcgZGVidWdmcyBmaWxlClByb2dyYW0gcmVjZWl2ZWQgc2lnbmFs
IFNJR1NFR1YsIFNlZ21lbnRhdGlvbiBmYXVsdC4KdW1yX3BtNF9kZWNvZGVfcmluZyAoYXNpYz1h
c2ljQGVudHJ5PTB4MWMwOGE1MCwgcmluZ25hbWU9PG9wdGltaXplZCBvdXQ+LCBub19oYWx0PW5v
X2hhbHRAZW50cnk9MSkgYXQgL2hvbWUvbWlraGFpbC9wYWNrYWdpbmctd29yay91bXIvc3JjL2xp
Yi91bXJfcmVhZF9wbTRfc3RyZWFtLmM6MzMzCjMzMwkJcmluZ2RhdGFbMF0gJT0gcmluZ3NpemU7
CihnZGIpIHRocmVhZCBhcHBseSBhbGwgYnQgZnVsbAoKVGhyZWFkIDEgKFRocmVhZCAweDdmZmZm
N2EyMjc0MCAoTFdQIDc4NDQpKToKIzAgIHVtcl9wbTRfZGVjb2RlX3JpbmcgKGFzaWM9YXNpY0Bl
bnRyeT0weDFjMDhhNTAsIHJpbmduYW1lPTxvcHRpbWl6ZWQgb3V0Piwgbm9faGFsdD1ub19oYWx0
QGVudHJ5PTEpIGF0IC9ob21lL21pa2hhaWwvcGFja2FnaW5nLXdvcmsvdW1yL3NyYy9saWIvdW1y
X3JlYWRfcG00X3N0cmVhbS5jOjMzMwogICAgICAgIHBzID0gPG9wdGltaXplZCBvdXQ+CiAgICAg
ICAgcmluZ2RhdGEgPSAweDAKICAgICAgICByaW5nc2l6ZSA9IDgxOTEKIzEgIDB4MDAwMDAwMDAw
MDRiNGFjNiBpbiB1bXJfcHJpbnRfd2F2ZXMgKGFzaWM9YXNpY0BlbnRyeT0weDFjMDhhNTApIGF0
IC9ob21lL21pa2hhaWwvcGFja2FnaW5nLXdvcmsvdW1yL3NyYy9hcHAvcHJpbnRfd2F2ZXMuYzo1
MgogICAgICAgIHggPSA8b3B0aW1pemVkIG91dD4KICAgICAgICB5ID0gPG9wdGltaXplZCBvdXQ+
CiAgICAgICAgc2hpZnQgPSA8b3B0aW1pemVkIG91dD4KICAgICAgICB0aHJlYWQgPSA8b3B0aW1p
emVkIG91dD4KICAgICAgICBwZ21fYWRkciA9IDxvcHRpbWl6ZWQgb3V0PgogICAgICAgIHNoYWRl
cl9hZGRyID0gPG9wdGltaXplZCBvdXQ+CiAgICAgICAgd2QgPSA8b3B0aW1pemVkIG91dD4KICAg
ICAgICBvd2QgPSA8b3B0aW1pemVkIG91dD4KICAgICAgICBmaXJzdCA9IDEKICAgICAgICBjb2wg
PSAwCiAgICAgICAgc2hhZGVyID0gMHgwCiAgICAgICAgc3RyZWFtID0gPG9wdGltaXplZCBvdXQ+
CiMyICAweDAwMDAwMDAwMDA0OTY5NTIgaW4gbWFpbiAoYXJnYz08b3B0aW1pemVkIG91dD4sIGFy
Z3Y9PG9wdGltaXplZCBvdXQ+KSBhdCAvaG9tZS9taWtoYWlsL3BhY2thZ2luZy13b3JrL3Vtci9z
cmMvYXBwL21haW4uYzoyODUKICAgICAgICBpID0gMwogICAgICAgIGogPSA8b3B0aW1pemVkIG91
dD4KICAgICAgICBrID0gPG9wdGltaXplZCBvdXQ+CiAgICAgICAgbCA9IDxvcHRpbWl6ZWQgb3V0
PgogICAgICAgIGFzaWMgPSAweDFjMDhhNTAKICAgICAgICBibG9ja25hbWUgPSA8b3B0aW1pemVk
IG91dD4KICAgICAgICBzdHIgPSA8b3B0aW1pemVkIG91dD4KICAgICAgICBzdHIyID0gPG9wdGlt
aXplZCBvdXQ+CiAgICAgICAgYXNpY25hbWUgPSAiXDAwMFwwMDBcMDAwXDAwMFwwMDQiLCAnXDAw
MCcgPHJlcGVhdHMgMTkgdGltZXM+LCAiRjtcMjI2XDAwMFwwMDBcMDAwXDAwMFwwMDBcMDAwXDAw
MFwwMDBcMDAwXDAwNCIsICdcMDAwJyA8cmVwZWF0cyAxOSB0aW1lcz4sICJcYSIsICdcMDAwJyA8
cmVwZWF0cyAxMSB0aW1lcz4sICJcMDA0IiwgJ1wwMDAnIDxyZXBlYXRzIDE5IHRpbWVzPiwgIlww
MjdcMzYyXDMyMVwwMDBcMDAwXDAwMFwwMDBcMDAwXDAwMFwwMDBcMDAwXDAwMFwwMDQiLCAnXDAw
MCcgPHJlcGVhdHMgMzEgdGltZXM+LCAiXDAwNCIsICdcMDAwJyA8cmVwZWF0cyAzMSB0aW1lcz4s
ICJcMDA0IiwgJ1wwMDAnIDxyZXBlYXRzIDMxIHRpbWVzPiwgIlwwMDQiLCAnXDAwMCcgPHJlcGVh
dHMgMzEgdGltZXM+Li4uCiAgICAgICAgaXBuYW1lID0gJ1wwMDAnIDxyZXBlYXRzIDI0IHRpbWVz
PiwgIkY7XDIyNiIsICdcMDAwJyA8cmVwZWF0cyAyOSB0aW1lcz4sICJsLW9wdGlvbiIsICdcMDAw
JyA8cmVwZWF0cyAyNCB0aW1lcz4sICJcMDA2XDAwMFwwMDBcMDAwXDAwMFwwMDBcMDAwXDIwMCIs
ICdcMDAwJyA8cmVwZWF0cyA1NiB0aW1lcz4sICJcMDI3XDM2MlwzMjEiLCAnXDAwMCcgPHJlcGVh
dHMgMjkgdGltZXM+LCAiXDAzNyIsICdcMDAwJyA8cmVwZWF0cyAzMSB0aW1lcz4uLi4KICAgICAg
ICByZWduYW1lID0gIlwwMDBcMDAwXDAwMFwwMDBcMDAwICIsICdcMDAwJyA8cmVwZWF0cyAxOCB0
aW1lcz4sICJcMDE3XDAwNCIsICdcMDAwJyA8cmVwZWF0cyAxMSB0aW1lcz4sICIgIiwgJ1wwMDAn
IDxyZXBlYXRzIDE4IHRpbWVzPiwgIlwyMjBcMzc3XDM3N1wzNzdcMzc3XDM3N1wzNzdcMzc3Iiwg
J1wwMDAnIDxyZXBlYXRzIDE2IHRpbWVzPiwgIlwwMzEiLCAnXDAwMCcgPHJlcGVhdHMgMTUgdGlt
ZXM+LCAiXGFcMDAwXDAwMFwwMDBcMDAwXDAwMFwwMDBcMDAwXDAzN1wwMDBcMDAwXDAwMFwwMDBc
MDAwXDAwMFwwMDBcMDAzXDAwMFwwMDBcMDAwXDAwMFwwMDBcMDAwXDAwMFwwMzBcMjIwXDI3NVww
MDFcMDAwXDAwMFwwMDBcMDAwUFwwMDBcMDAwXDAwMFwwMDBcMDAwXDAwMFwwMDBcMjIwXDM3N1wz
NzdcMzc3XDM3N1wzNzdcMzc3XDM3N1wwMDBcMDAwXDAwMFwwMDBcMDAwXDAwMFwwMDBcMDAwXDAw
M1wwMDBcMDAwXDAwMHdcMDAwXDAwMFwwMDBbXDAwMFwwMDBcMDAwXDA2MCIsICdcMDAwJyA8cmVw
ZWF0cyAyNyB0aW1lcz4sICJuXDAwMFwwMDBcMDAwfCIsICdcMDAwJyA8cmVwZWF0cyAxOSB0aW1l
cz4uLi4KICAgICAgICByZXEgPSB7dHZfc2VjID0gMCwgdHZfbnNlYyA9IDczMTA4Njg3MzU5NTYx
ODQxNjF9CihnZGIpIAo=
--000000000000aba022057d669a4b--
