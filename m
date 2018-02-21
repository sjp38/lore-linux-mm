Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 157326B0008
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:47:21 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id o61so737302pld.5
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 04:47:21 -0800 (PST)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id 33-v6si2269422plg.227.2018.02.21.04.47.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 04:47:20 -0800 (PST)
From: "Wangxuefeng (E)" <wxf.wang@hisilicon.com>
Subject: =?gb2312?B?tPC4tDogtPC4tDogW1JGQyBwYXRjaF0gaW9yZW1hcDogZG9uJ3Qgc2V0IHVw?=
 =?gb2312?Q?_huge_I/O_mappings_when_p4d/pud/pmd_is_zero?=
Date: Wed, 21 Feb 2018 12:47:11 +0000
Message-ID: <etPan.5a8d6a4e.278c448b.3d0e@localhost>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
 <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
 <1519175992.16384.121.camel@hpe.com>
 <etPan.5a8d2180.1dbfd272.49b8@localhost>,<20180221115758.GA7614@arm.com>
In-Reply-To: <20180221115758.GA7614@arm.com>
Content-Language: zh-CN
Content-Type: multipart/alternative;
	boundary="_000_etPan5a8d6a4e278c448b3d0elocalhost_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon" <will.deacon@arm.com>
Cc: "toshi.kani" <toshi.kani@hpe.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, cpandya <cpandya@codeaurora.org>, linux-kernel <linux-kernel@vger.kernel.org>, "Guohanjun (Hanjun Guo)" <guohanjun@huawei.com>, Linuxarm <linuxarm@huawei.com>, linux-mm <linux-mm@kvack.org>, akpm <akpm@linux-foundation.org>, "mark.rutland" <mark.rutland@arm.com>, "catalin.marinas" <catalin.marinas@arm.com>, mhocko <mhocko@suse.com>, "hanjun.guo" <hanjun.guo@linaro.org>

--_000_etPan5a8d6a4e278c448b3d0elocalhost_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

SGksIFdpbGwNCiAgICAgICBUaGFua3MgZm9yIHlvdXIgZXhwbGFpbi4gSWYgcG1kIGNsZWFyZWQg
bWVhbnMgbWFraW5nIHRoZSBwbWQgYW4gaW52YWxpZCBlbnRyeaOsdGhhdKGvIHMgbm8gcHJvYmxl
bS4NClRoYW5rcw0KICAgICAgIFdhbmd4dWVmZW5nDQoNClNlbnQgZnJvbSBIVUFXRUkgQW55T2Zm
aWNlDQq3orz+yMujundpbGwuZGVhY29uDQrK1bz+yMujug0Ks63LzaO6dG9zaGkua2FuaSxsaW51
eC1hcm0ta2VybmVsLGNwYW5keWEsbGludXgta2VybmVsLLn5uq6+/CxMaW51eGFybSxsaW51eC1t
bSxha3BtLG1hcmsucnV0bGFuZCxjYXRhbGluLm1hcmluYXMsbWhvY2tvLGhhbmp1bi5ndW8NCsqx
vOSjujIwMTgtMDItMjEgMTk6NTg6MTUNCtb3zOI6UmU6ILTwuLQ6IFtSRkMgcGF0Y2hdIGlvcmVt
YXA6IGRvbid0IHNldCB1cCBodWdlIEkvTyBtYXBwaW5ncyB3aGVuIHA0ZC9wdWQvcG1kIGlzIHpl
cm8NCg0KW3NvcnJ5LCB0cnlpbmcgdG8gZGVhbCB3aXRoIHRvcC1wb3N0aW5nIGhlcmVdDQoNCk9u
IFdlZCwgRmViIDIxLCAyMDE4IGF0IDA3OjM2OjM0QU0gKzAwMDAsIFdhbmd4dWVmZW5nIChFKSB3
cm90ZToNCj4gICAgICBUaGUgb2xkIGZsb3cgb2YgcmV1c2UgdGhlIDRrIHBhZ2UgYXMgMk0gcGFn
ZSBkb2VzIG5vdCBmb2xsb3cgdGhlIEJCTSBmbG93DQo+IGZvciBwYWdlIHRhYmxlIHJlY29uc3Ry
dWN0aW9uo6xub3Qgb25seSB0aGUgbWVtb3J5IGxlYWsgcHJvYmxlbXMuICBJZiBCQk0gZmxvdw0K
PiBpcyBub3QgZm9sbG93ZWSjrHRoZSBzcGVjdWxhdGl2ZSBwcmVmZXRjaCBvZiB0bGIgd2lsbCBt
YWRlIGZhbHNlIHRsYiBlbnRyaWVzDQo+IGNhY2hlZCBpbiBNTVUsIHRoZSBmYWxzZSBhZGRyZXNz
IHdpbGwgYmUgZ290o6wgcGFuaWMgd2lsbCBoYXBwZW4uDQoNCklmIEkgdW5kZXJzdGFuZCBUb3No
aSdzIHN1Z2dlc3Rpb24gY29ycmVjdGx5LCBoZSdzIHNheWluZyB0aGF0IHRoZSBQTUQgY2FuDQpi
ZSBjbGVhcmVkIHdoZW4gdW5tYXBwaW5nIHRoZSBsYXN0IFBURSAobGlrZSB0cnlfdG9fZnJlZV9w
dGVfcGFnZSkuIEluIHRoaXMNCmNhc2UsIHRoZXJlJ3Mgbm8gaXNzdWUgd2l0aCB0aGUgVExCIGJl
Y2F1c2UgdGhpcyBpcyBleGFjdGx5IEJCTSAtLSB0aGUgUE1EDQppcyBjbGVhcmVkIGFuZCBUTEIg
aW52YWxpZGF0aW9uIGlzIGlzc3VlZCBiZWZvcmUgdGhlIFBURSB0YWJsZSBpcyBmcmVlZC4gQQ0K
c3Vic2VxdWVudCAyTSBtYXAgcmVxdWVzdCB3aWxsIHNlZSBhbiBlbXB0eSBQTUQgYW5kIHB1dCBk
b3duIGEgYmxvY2sNCm1hcHBpbmcuDQoNClRoZSBkb3duc2lkZSBpcyB0aGF0IGZyZWVpbmcgYmVj
b21lcyBtb3JlIGV4cGVuc2l2ZSBhcyB0aGUgbGFzdCBsZXZlbCB0YWJsZQ0KYmVjb21lcyBtb3Jl
IHNwYXJzZWx5IHBvcHVsYXRlZCBhbmQgeW91IG5lZWQgdG8gZW5zdXJlIHlvdSBkb24ndCBoYXZl
IGFueQ0KY29uY3VycmVudCBtYXBzIGdvaW5nIG9uIGZvciB0aGUgc2FtZSB0YWJsZSB3aGVuIHlv
dSdyZSB1bm1hcHBpbmcuIEkgYWxzbw0KY2FuJ3Qgc2VlIGEgbmVhdCB3YXkgdG8gZml0IHRoaXMg
aW50byB0aGUgY3VycmVudCB2dW5tYXAgY29kZS4gUGVyaGFwcyB3ZQ0KbmVlZCBhbiBpb3VubWFw
X3BhZ2VfcmFuZ2UuDQoNCkluIHRoZSBtZWFudGltZSwgdGhlIGNvZGUgaW4gbGliL2lvcmVtYXAu
YyBsb29rcyB0b3RhbGx5IGJyb2tlbiBzbyBJIHRoaW5rDQp3ZSBzaG91bGQgZGVzZWxlY3QgQ09O
RklHX0hBVkVfQVJDSF9IVUdFX1ZNQVAgb24gYXJtNjQgdW50aWwgaXQncyBmaXhlZC4NCg0KV2ls
bA0K

--_000_etPan5a8d6a4e278c448b3d0elocalhost_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<meta name=3D"Generator" content=3D"Microsoft Exchange Server">
<!-- converted from text --><style><!-- .EmailQuote { margin-left: 1pt; pad=
ding-left: 4pt; border-left: #800000 2px solid; } --></style>
</head>
<body>
<div>
<div>Hi, Will<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thanks for your explain. If pmd cleare=
d means making the pmd an invalid entry=A3=ACthat=A1=AF s no problem.<br>
Thanks<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Wangxuefeng<br>
<br>
Sent from HUAWEI AnyOffice<br>
</div>
<div name=3D"x_AnyOffice-Background-Image" style=3D"border-top:1px solid #B=
5C4DF; font-size:14px; line-height:20px; padding:8px">
<div style=3D"word-break:break-all"><b>=B7=A2=BC=FE=C8=CB=A3=BA</b>will.dea=
con</div>
<div style=3D"word-break:break-all"><b>=CA=D5=BC=FE=C8=CB=A3=BA</b></div>
<div style=3D"word-break:break-all"><b>=B3=AD=CB=CD=A3=BA</b>toshi.kani,lin=
ux-arm-kernel,cpandya,linux-kernel,=B9=F9=BA=AE=BE=FC,Linuxarm,linux-mm,akp=
m,mark.rutland,catalin.marinas,mhocko,hanjun.guo</div>
<div style=3D"word-break:break-all"><b>=CA=B1=BC=E4=A3=BA</b>2018-02-21 19:=
58:15</div>
<div style=3D"word-break:break-all"><b>=D6=F7=CC=E2:</b>Re: =B4=F0=B8=B4: [=
RFC patch] ioremap: don't set up huge I/O mappings when p4d/pud/pmd is zero=
</div>
<div><br>
</div>
</div>
</div>
<font size=3D"2"><span style=3D"font-size:10pt;">
<div class=3D"PlainText">[sorry, trying to deal with top-posting here]<br>
<br>
On Wed, Feb 21, 2018 at 07:36:34AM &#43;0000, Wangxuefeng (E) wrote:<br>
&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The old flow of reuse the 4k page as 2M =
page does not follow the BBM flow<br>
&gt; for page table reconstruction=A3=ACnot only the memory leak problems.&=
nbsp; If BBM flow<br>
&gt; is not followed=A3=ACthe speculative prefetch of tlb will made false t=
lb entries<br>
&gt; cached in MMU, the false address will be got=A3=AC panic will happen.<=
br>
<br>
If I understand Toshi's suggestion correctly, he's saying that the PMD can<=
br>
be cleared when unmapping the last PTE (like try_to_free_pte_page). In this=
<br>
case, there's no issue with the TLB because this is exactly BBM -- the PMD<=
br>
is cleared and TLB invalidation is issued before the PTE table is freed. A<=
br>
subsequent 2M map request will see an empty PMD and put down a block<br>
mapping.<br>
<br>
The downside is that freeing becomes more expensive as the last level table=
<br>
becomes more sparsely populated and you need to ensure you don't have any<b=
r>
concurrent maps going on for the same table when you're unmapping. I also<b=
r>
can't see a neat way to fit this into the current vunmap code. Perhaps we<b=
r>
need an iounmap_page_range.<br>
<br>
In the meantime, the code in lib/ioremap.c looks totally broken so I think<=
br>
we should deselect CONFIG_HAVE_ARCH_HUGE_VMAP on arm64 until it's fixed.<br=
>
<br>
Will<br>
</div>
</span></font>
</body>
</html>

--_000_etPan5a8d6a4e278c448b3d0elocalhost_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
