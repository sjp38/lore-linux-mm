Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC806B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 22:54:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so4942975pfc.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 19:54:38 -0700 (PDT)
Received: from smtpbg302.qq.com (smtpbg302.qq.com. [184.105.206.27])
        by mx.google.com with ESMTPS id c10si20354566pat.170.2016.05.31.19.54.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 19:54:37 -0700 (PDT)
Date: Wed, 1 Jun 2016 10:54:27 +0800
From: "shhuiw@foxmail.com" <shhuiw@foxmail.com>
Subject: Re: Re: why use alloc_workqueue instead of create_singlethread_workqueue to create nvme_workq
References: <tencent_4323E1CE03D759181B6B4507@qq.com>,
	<20160531145306.GB24107@localhost.localdomain>
Mime-Version: 1.0
Message-ID: <2016060110542407705011@foxmail.com>
Content-Type: multipart/alternative;
	boundary="----=_001_NextPart033558812640_=----"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "keith.busch" <keith.busch@intel.com>
Cc: "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

This is a multi-part message in MIME format.

------=_001_NextPart033558812640_=----
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: base64

VGhhbmtzLCBLZWl0aCENCg0KQW55IGlkZWEgb24gaG93IHRvIGZpeCB0aGUgd2FybmluZz8gSnVz
dCBkcm9wIHRoZSBXUV9NRU1fUkVDTEFJTSBmb3IgbnZtZV93b3JrcSwgb3INCmxydSBkcmFpbiB3
b3JrIHNjaGVkdWxlIHNob3VsZCBiZSBjaGFuZ2VkPw0KDQoNCk9uIFR1ZSwgTWF5IDMxLCAyMDE2
IGF0IDA0OjQzOjM0UE0gKzA4MDAsIFdhbmcgU2hlbmctSHVpIHdyb3RlOg0KPiBSZWNlbnRseSBJ
IG5vdGljZWQgd2FybmluZyBvbiBOVk1FIHByb2JlIGlmIENNQSBpcyBlbmFibGVkIG9uIG15IFNv
QyBwbGF0Zm9ybQ0KPiAoWk9ORV9ETUEsIFpPTkVfRE1BMzIgYW5kIENNQSBlbmFibGVkIGluIHRo
ZSBjb25maWcgZmlsZSk6DQo+IC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+IFdBUk5JTkc6IENQ
VTogMCBQSUQ6IDYgYXQgbGludXgva2VybmVsL3dvcmtxdWV1ZS5jOjI0NDggY2hlY2tfZmx1c2hf
ZGVwZW5kZW5jeSsweGI0LzB4MTBjDQo+IFsgICAgMC4xNTQwODNdIFs8ZmZmZmZjMDAwODBkNmRl
MD5dIGNoZWNrX2ZsdXNoX2RlcGVuZGVuY3krMHhiNC8weDEwYw0KPiBbICAgIDAuMTU0MDg4XSBb
PGZmZmZmYzAwMDgwZDhlODA+XSBmbHVzaF93b3JrKzB4NTQvMHgxNDANCj4gWyAgICAwLjE1NDA5
Ml0gWzxmZmZmZmMwMDA4MTY2YTBjPl0gbHJ1X2FkZF9kcmFpbl9hbGwrMHgxMzgvMHgxODgNCj4g
WyAgICAwLjE1NDA5N10gWzxmZmZmZmMwMDA4MWFiMmRjPl0gbWlncmF0ZV9wcmVwKzB4Yy8weDE4
DQo+IFsgICAgMC4xNTQxMDFdIFs8ZmZmZmZjMDAwODE2MGU4OD5dIGFsbG9jX2NvbnRpZ19yYW5n
ZSsweGY0LzB4MzUwDQo+IFsgICAgMC4xNTQxMDVdIFs8ZmZmZmZjMDAwODFiY2VmOD5dIGNtYV9h
bGxvYysweGVjLzB4MWU0DQo+IFsgICAgMC4xNTQxMTBdIFs8ZmZmZmZjMDAwODQ0NmFkMD5dIGRt
YV9hbGxvY19mcm9tX2NvbnRpZ3VvdXMrMHgzOC8weDQwDQo+IFsgICAgMC4xNTQxMTRdIFs8ZmZm
ZmZjMDAwODBhMDkzYz5dIF9fZG1hX2FsbG9jKzB4NzQvMHgyNWMNCj4gWyAgICAwLjE1NDExOV0g
WzxmZmZmZmMwMDA4NDgyOGQ4Pl0gbnZtZV9hbGxvY19xdWV1ZSsweGNjLzB4MzZjDQo+IFsgICAg
MC4xNTQxMjNdIFs8ZmZmZmZjMDAwODQ4NGIyYz5dIG52bWVfcmVzZXRfd29yaysweDVjNC8weGRh
OA0KPiBbICAgIDAuMTU0MTI4XSBbPGZmZmZmYzAwMDgwZDk1Mjg+XSBwcm9jZXNzX29uZV93b3Jr
KzB4MTI4LzB4MmVjDQo+IFsgICAgMC4xNTQxMzJdIFs8ZmZmZmZjMDAwODBkOTc0ND5dIHdvcmtl
cl90aHJlYWQrMHg1OC8weDQzNA0KPiBbICAgIDAuMTU0MTM2XSBbPGZmZmZmYzAwMDgwZGYwZWM+
XSBrdGhyZWFkKzB4ZDQvMHhlOA0KPiBbICAgIDAuMTU0MTQxXSBbPGZmZmZmYzAwMDgwOTNhYzA+
XSByZXRfZnJvbV9mb3JrKzB4MTAvMHg1MA0KIA0KVGhlIGxydSBkcmFpbiB3b3JrIGlzIHNjaGVk
dWxlZCBvbiB0aGUgc3lzdGVtIHdvcmsgcXVldWUsIHdoaWNoIGlzIG5vdA0KdXNlZCBmb3IgbWVt
b3J5IHJlY2xhaW0uIEJ1dCB0aGlzIHdvcmsgaXMgdXNlZCBmb3Igc3dhcCwgc28gbWF5YmUgaXQN
CnNob3VsZCBiZSBzY2hlZHVsZWQgb24gYSBzdWNoIGEgd29yayBxdWV1ZSwgYW5kIHRoaXMgd2Fy
bmluZyB3b3VsZCBnbw0KYXdheS4gVW5sZXNzIHRoZXJlJ3MgYSByZWFzb24gbm90IHRvIGhhdmUg
YSBzeXN0ZW0gbWVtb3J5IHJlY2xhaW0gd29yaw0KcXVldWUsIEknbGwgbG9vayBpbnRvIHRoYXQu
DQogDQo+IEJ1dCB0aGUgbG9nIG9ubHkgZXhwbGFpbmVkIHdoeSBjaGFuZ2VkIHRvIHdvcmtxdWV1
ZSBpbnN0ZWFkIG9mIHNjaGVkdWxlX3dvcmssIA0KPiBubyBjb21tZW50cyB3aHkgdXNlIGFsbG9j
X3dvcmtxdWV1ZSBpbnN0ZWFkIG9mIGNyZWF0ZV9zaW5nbGV0aHJlYWRfd29ya3F1ZXVlLA0KPiB0
aG91Z2ggDQogDQpXZSByZW1vdmVkIHNpbmdsZSB0aHJlYWRlZCB3b3JrIHF1ZXVlcyBzbyBtdWx0
aXBsZSBjb250cm9sbGVycyBjYW4gYmUNCnByb2JlZCBpbiBwYXJhbGxlbC4NCiANCj4gICAgICAg
ICJUaGUgb3JpZ2luYWwgY3JlYXRlXyp3b3JrcXVldWUoKSBmdW5jdGlvbnMgYXJlIGRlcHJlY2F0
ZWQgYW5kIHNjaGVkdWxlZCBmb3IgcmVtb3ZhbC4iIA0KPiAoRG9jdW1lbnRhdGlvbi93b3JrcXVl
dWUudHh0OyBodHRwczovL3BhdGNod29yay5vemxhYnMub3JnL3BhdGNoLzU3NTU3MC8pLiANCj4g
DQo+IFRoZSBrZXkgcG9pbnQgaXMgIl9fV1FfTEVHQUNZIiB3YXMgZHJvcHBlZC4gDQo+IElmIEkg
Y2hhbmdlIHRvIHVzZSAibnZtZV93b3JrcSA9IGNyZWF0ZV9zaW5nbGV0aHJlYWRfd29ya3F1ZXVl
KCJudm1lIik7IiwgIHRoZW4gbm8NCj4gd2FybmluZyBvbiBOVk1FIHByb2JlIGluIG15IGNhc2Uu
DQo+IA0KPiBNeSBxdWVzdGlvbiBpcywgd2h5IHlvdSBkZWNpZGUgZHJvcCB0aGUgZmxhZyAiX19X
UV9MRUdBQ1kiIGZvciBudm1lX3dvcmtxPw0KIA0KSSBkaWRuJ3QgZGVjaWRlIHRvIGRyb3AgdGhp
cy4gVGhlIGZsYWcgaXMgdXNlZCBmb3IgZGVwcmVjYXRlZCB1c2FnZSwNCmJ1dCB0aGlzIGlzIG5l
dyB1c2FnZS4NCiANCkkgdGhpbmsgdGhlIHJlYWwgaXNzdWUgaXMgbnZtZSB1c2VzIGEgV1FfTUVN
X1JFQ0xBSU0gd29yayBxdWV1ZSBidXQgc3dhcA0KZG9lcyBub3QuIE9uZSBvZiB0aGVzZSBwcm9i
YWJseSBuZWVkcyB0byBjaGFuZ2UuDQogDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXw0KTGludXgtbnZtZSBtYWlsaW5nIGxpc3QNCkxpbnV4LW52bWVAbGlz
dHMuaW5mcmFkZWFkLm9yZw0KaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0
aW5mby9saW51eC1udm1lDQogDQoNCg0KUmVnYXJkcywNClNoZW5nLUh1aQ0KDQoNCg==

------=_001_NextPart033558812640_=----
Content-Type: text/html;
	charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charse=
t=3DISO-8859-1"><style>body { line-height: 1.5; }blockquote { margin-top: =
0px; margin-bottom: 0px; margin-left: 0.5em; }body { font-size: 10.5pt; fo=
nt-family: 'Segoe UI'; color: rgb(0, 0, 0); line-height: 1.5; }</style></h=
ead><body>=0A<div style=3D"font-size: 16px;">Thanks, Keith!</div><div styl=
e=3D"font-size: 16px;"><br></div><div><span style=3D"font-size: 16px;">Any=
 idea on how to fix the warning? Just drop the&nbsp;</span><span style=3D"=
font-size: medium; line-height: normal; background-color: window;">WQ_MEM_=
RECLAIM for nvme_workq, or</span></div><div><font size=3D"3"><span style=
=3D"line-height: normal;">lru drain work schedule should be changed?</span=
></font></div><div><br></div><div><br></div><div><table width=3D"100%"><tb=
ody><tr><td width=3D"100%"><blockquote style=3D"BORDER-LEFT: #000000 2px s=
olid; MARGIN-LEFT: 5px; MARGIN-RIGHT: 0px; PADDING-LEFT: 5px; PADDING-RIGH=
T: 0px"><div>On Tue, May 31, 2016 at 04:43:34PM +0800, Wang Sheng-Hui wrot=
e:</div>=0A<div>&gt; Recently I noticed warning on NVME probe if CMA is en=
abled on my SoC platform</div>=0A<div>&gt; (ZONE_DMA, ZONE_DMA32 and CMA e=
nabled in the config file):</div>=0A<div>&gt; ----------------------------=
----------------------------------------------------</div>=0A<div>&gt; WAR=
NING: CPU: 0 PID: 6 at linux/kernel/workqueue.c:2448 check_flush_dependenc=
y+0xb4/0x10c</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154083] [&lt;fffffc00=
080d6de0&gt;] check_flush_dependency+0xb4/0x10c</div>=0A<div>&gt; [&nbsp;&=
nbsp;&nbsp; 0.154088] [&lt;fffffc00080d8e80&gt;] flush_work+0x54/0x140</di=
v>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154092] [&lt;fffffc0008166a0c&gt;] lr=
u_add_drain_all+0x138/0x188</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154097=
] [&lt;fffffc00081ab2dc&gt;] migrate_prep+0xc/0x18</div>=0A<div>&gt; [&nbs=
p;&nbsp;&nbsp; 0.154101] [&lt;fffffc0008160e88&gt;] alloc_contig_range+0xf=
4/0x350</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154105] [&lt;fffffc00081bc=
ef8&gt;] cma_alloc+0xec/0x1e4</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.1541=
10] [&lt;fffffc0008446ad0&gt;] dma_alloc_from_contiguous+0x38/0x40</div>=
=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154114] [&lt;fffffc00080a093c&gt;] __dm=
a_alloc+0x74/0x25c</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154119] [&lt;ff=
fffc00084828d8&gt;] nvme_alloc_queue+0xcc/0x36c</div>=0A<div>&gt; [&nbsp;&=
nbsp;&nbsp; 0.154123] [&lt;fffffc0008484b2c&gt;] nvme_reset_work+0x5c4/0xd=
a8</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154128] [&lt;fffffc00080d9528&g=
t;] process_one_work+0x128/0x2ec</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.1=
54132] [&lt;fffffc00080d9744&gt;] worker_thread+0x58/0x434</div>=0A<div>&g=
t; [&nbsp;&nbsp;&nbsp; 0.154136] [&lt;fffffc00080df0ec&gt;] kthread+0xd4/0=
xe8</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.154141] [&lt;fffffc0008093ac0&=
gt;] ret_from_fork+0x10/0x50</div>=0A<div>&nbsp;</div>=0A<div>The lru drai=
n work is scheduled on the system work queue, which is not</div>=0A<div>us=
ed for memory reclaim. But this work is used for swap, so maybe it</div>=
=0A<div>should be scheduled on a such a work queue, and this warning would=
 go</div>=0A<div>away. Unless there's a reason not to have a system memory=
 reclaim work</div>=0A<div>queue, I'll look into that.</div>=0A<div>&nbsp;=
</div>=0A<div>&gt; But the log only explained why changed to workqueue ins=
tead of schedule_work, </div>=0A<div>&gt; no comments why use alloc_workqu=
eue instead of create_singlethread_workqueue,</div>=0A<div>&gt; though </d=
iv>=0A<div>&nbsp;</div>=0A<div>We removed single threaded work queues so m=
ultiple controllers can be</div>=0A<div>probed in parallel.</div>=0A<div>&=
nbsp;</div>=0A<div>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; "The ori=
ginal create_*workqueue() functions are deprecated and scheduled for remov=
al." </div>=0A<div>&gt; (Documentation/workqueue.txt; https://patchwork.oz=
labs.org/patch/575570/). </div>=0A<div>&gt; </div>=0A<div>&gt; The key poi=
nt is "__WQ_LEGACY" was dropped. </div>=0A<div>&gt; If I change to use "nv=
me_workq =3D create_singlethread_workqueue("nvme");",&nbsp; then no</div>=
=0A<div>&gt; warning on NVME probe in my case.</div>=0A<div>&gt; </div>=0A=
<div>&gt; My question is, why you decide drop the flag "__WQ_LEGACY" for n=
vme_workq?</div>=0A<div>&nbsp;</div>=0A<div>I didn't decide to drop this. =
The flag is used for deprecated usage,</div>=0A<div>but this is new usage.=
</div>=0A<div>&nbsp;</div>=0A<div>I think the real issue is nvme uses a WQ=
_MEM_RECLAIM work queue but swap</div>=0A<div>does not. One of these proba=
bly needs to change.</div>=0A<div>&nbsp;</div>=0A<div>____________________=
___________________________</div>=0A<div>Linux-nvme mailing list</div>=0A<=
div>Linux-nvme@lists.infradead.org</div>=0A<div>http://lists.infradead.org=
/mailman/listinfo/linux-nvme</div>=0A<div>&nbsp;</div>=0A</blockquote></td=
></tr></tbody></table></div><div><br></div><div><span></span></div><div><b=
r></div><div><span><div style=3D"MARGIN: 10px; FONT-FAMILY: verdana; FONT-=
SIZE: 10pt"><div>Regards,</div><div>Sheng-Hui</div></div></span></div><div=
><br></div><div><br></div><blockquote style=3D"margin-Top: 0px; margin-Bot=
tom: 0px; margin-Left: 0.5em"><div>=0A</div></blockquote></body></html>
------=_001_NextPart033558812640_=------



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
