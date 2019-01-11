Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42D288E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:28:51 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id s193so150513wmd.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:28:51 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40065.outbound.protection.outlook.com. [40.107.4.65])
        by mx.google.com with ESMTPS id a8si42513176wrx.222.2019.01.10.17.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 17:28:49 -0800 (PST)
From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected huge
 vmap mappings
Date: Fri, 11 Jan 2019 01:28:46 +0000
Message-ID: 
 <VI1PR0402MB3600E7160A2921A8D3DCA055FF850@VI1PR0402MB3600.eurprd04.prod.outlook.com>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
 <20181226145048.GA24307@infradead.org>
 <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20181227121901.GA20892@infradead.org>
 <VI1PR0402MB3600799A06B6BFE5EBF8837FFFB70@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <VI1PR0402MB36000BD05AF4B242E13D9D05FF840@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20190110140726.GA6223@infradead.org>
In-Reply-To: <20190110140726.GA6223@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

RnJvbTogQ2hyaXN0b3BoIEhlbGx3aWcgPG1haWx0bzpoY2hAaW5mcmFkZWFkLm9yZz4gU2VudDog
MjAxOcTqMdTCMTDI1SAyMjowNw0KPiBPbiBUaHUsIEphbiAxMCwgMjAxOSBhdCAwMTo0NToyMEFN
ICswMDAwLCBBbmR5IER1YW4gd3JvdGU6DQo+ID4gRG8geW91IGhhdmUgYW55IG90aGVyIGNvbW1l
bnRzIGZvciB0aGUgcGF0Y2ggPw0KPiA+IEN1cnJlbnQgZHJpdmVyIGJyZWFrIHJlbW90ZXByb2Mg
b24gTlhQIGkuTVg4IHBsYXRmb3JtICwgdGhlIHBhdGNoIGlzIGJ1Z2ZpeA0KPiB0aGUgdmlydGlv
IHJwbXNnIGJ1cywgd2UgaG9wZSB0aGUgcGF0Y2ggZW50ZXIgdG8gbmV4dCBhbmQgc3RhYmxlIHRy
ZWUgaWYgbm8NCj4gb3RoZXIgY29tbWVudHMuDQo+IA0KPiBUaGUgYW5zd2VyIHJlbWFpbnMgdGhh
dCB5b3UgQ0FOIE5PVCBjYWxsIHZtYWxsb2NfdG9fcGFnZSBvciB2aXJ0X3RvX3BhZ2UNCj4gb24g
RE1BIGNvaGVyZW50IG1lbW9yeSwgYW5kIHRoZSBkcml2ZXIgaGFzIGJlZW4gYnJva2VuIGV2ZXIg
c2luY2UgaXQgd2FzDQo+IG1lcmdlZC4gIFdlIG5lZWQgdG8gZml4IHRoZSByb290IGNhdXNlIGFu
ZCBub3QgdGhlIHN5bXB0b20uDQoNCkFzIE5YUCBpLk1YOCBwbGF0Zm9ybSByZXF1aXJlbWVudCB0
aGF0IE00IG9ubHkgYWNjZXNzIHRoZSBmaXhlZCBtZW1vcnkgcmVnaW9uLCBzbyBkbw0KWW91IGhh
dmUgYW55IHN1Z2dlc3Rpb24gdG8gZml4IHRoZSBpc3N1ZSBhbmQgc2F0aXNmeSB0aGUgcmVxdWly
ZW1lbnQgPyBPciBkbyB5b3UgaGF2ZSBwbGFuDQpUbyBmaXggdGhlIHJvb3QgY2F1c2UgPw0KDQpU
aGFua3MuDQo=
