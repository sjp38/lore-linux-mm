Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC5E96B0266
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:38:42 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t11-v6so4376208iog.15
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 23:38:42 -0700 (PDT)
Received: from mail.wingtech.com (mail.wingtech.com. [180.166.216.14])
        by mx.google.com with ESMTPS id d129-v6si2838518itc.67.2018.07.24.23.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Jul 2018 23:38:41 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:37:58 +0800
From: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Subject: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Mime-Version: 1.0
Message-ID: <2018072514375722198958@wingtech.com>
Content-Type: multipart/alternative;
	boundary="----=_001_NextPart513000047512_=----"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman <mgorman@techsingularity.net>, akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>
Cc: vinmenon <vinmenon@codeaurora.org>, mhocko <mhocko@suse.com>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.

------=_001_NextPart513000047512_=----
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: base64

RnJvbTogemhhb3d1eXVuIDx6aGFvd3V5dW5Ad2luZ3RlY2guY29tPg0KIA0KaXNzdWUgaXMgdGhh
dCB0aGVyZSBhcmUgdHdvIHByb2Nlc3NlcyBBIGFuZCBCLCBBIGlzIGt3b3JrZXIvdTE2OjgNCm5v
cm1hbCBwcmlvcml0eSwgQiBpcyBBdWRpb1RyYWNrLCBSVCBwcmlvcml0eSwgdGhleSBhcmUgb24g
dGhlDQpzYW1lIENQVSAzLg0KIA0KVGhlIHRhc2sgQSBwcmVlbXB0ZWQgYnkgdGFzayBCIGluIHRo
ZSBtb21lbnQNCmFmdGVyIF9fZGVsZXRlX2Zyb21fc3dhcF9jYWNoZShwYWdlKSBhbmQgYmVmb3Jl
IHN3YXBjYWNoZV9mcmVlKHN3YXApLg0KIA0KVGhlIHRhc2sgQiBkb2VzIF9fcmVhZF9zd2FwX2Nh
Y2hlX2FzeW5jIGluIHRoZSBkbyB7fSB3aGlsZSBsb29wLCBpdA0Kd2lsbCBuZXZlciBmaW5kIHRo
ZSBwYWdlIGZyb20gc3dhcHBlcl9zcGFjZSBiZWNhdXNlIHRoZSBwYWdlIGlzIHJlbW92ZWQNCmJ5
IHRoZSB0YXNrIEEsIGFuZCBpdCB3aWxsIG5ldmVyIHN1Y2Vzc2Z1bGx5IGluIHN3YXBjYWNoZV9w
cmVwYXJlIGJlY2F1c2UNCnRoZSBlbnRyeSBpcyBFRVhJU1QuDQogDQpUaGUgdGFzayBCIHRoZW4g
c3R1Y2sgaW4gdGhlIGxvb3AgaW5maW5pdGVseSBiZWNhdXNlIGl0IGlzIGEgUlQgdGFzaywNCm5v
IG9uZSBjYW4gcHJlZW1wdCBpdC4NCiANCnNvIG5lZWQgdG8gZGlzYWJsZSBwcmVlbXB0aW9uIHVu
dGlsIHRoZSBzd2FwY2FjaGVfZnJlZSBleGVjdXRlZC4NCiANClRBU0sgQToNCj09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09DQpQcm9jZXNzOiBrd29y
a2VyL3UxNjo4LCBjcHU6IDMgcGlkOiAyMDI4OSBzdGFydDogMHhmZmZmZmZjMDM4NWY4ZTAwDQo9
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0KICAg
IFRhc2sgbmFtZToga3dvcmtlci91MTY6OCBwaWQ6IDIwMjg5IGNwdTogMyBzdGFydDogZmZmZmZm
YzAzODVmOGUwMA0KICAgIHN0YXRlOiAweDAgZXhpdF9zdGF0ZTogMHgwIHN0YWNrIGJhc2U6IDB4
ZmZmZmZmYzAxMmJhMDAwMCBQcmlvOiAxMjANCiAgICBTdGFjazoNCiAgICBbPGZmZmZmZjgwYmNh
ODYxYTQ+XSBfX3N3aXRjaF90bysweDkwDQogICAgWzxmZmZmZmY4MGJkODNlZGRjPl0gX19zY2hl
ZHVsZSsweDI5Yw0KICAgIFs8ZmZmZmZmODBiZDgzZjYwMD5dIHByZWVtcHRfc2NoZWR1bGVfY29t
bW9uKzB4MjQNCiAgICBbPGZmZmZmZjgwYmQ4M2Y2M2M+XSBwcmVlbXB0X3NjaGVkdWxlLnBhcnQu
MTY5KzB4MWMNCiAgICBbPGZmZmZmZjgwYmQ4M2Y2NjQ+XSBwcmVlbXB0X3NjaGVkdWxlKzB4MjAN
CiAgICBbPGZmZmZmZjgwYmQ4NDM5NmM+XSBfcmF3X3NwaW5fdW5sb2NrX2lycXJlc3RvcmUrMHg0
MA0KICAgIFs8ZmZmZmZmODBiY2JjNDcxMD5dIF9fcmVtb3ZlX21hcHBpbmcrMHgxNzQNCiAgICBb
PGZmZmZmZjgwYmNiYzc2OTg+XSBzaHJpbmtfcGFnZV9saXN0KzB4ODk0DQogICAgWzxmZmZmZmY4
MGJjYmM3ZDdjPl0gcmVjbGFpbV9wYWdlc19mcm9tX2xpc3QrMHhjOA0KICAgIFs8ZmZmZmZmODBi
Y2M3YjkxMD5dIHJlY2xhaW1fcHRlX3JhbmdlKzB4MTU4DQogICAgWzxmZmZmZmY4MGJjYmY0NWQ0
Pl0gd2Fsa19wZ2RfcmFuZ2UrMHhkNA0KICAgIFs8ZmZmZmZmODBiY2JmNDc2Yz5dIHdhbGtfcGFn
ZV9yYW5nZSsweDc0DQogICAgWzxmZmZmZmY4MGJjYzdjZDY0Pl0gcmVjbGFpbV90YXNrX2Fub24r
MHhkYw0KICAgIFs8ZmZmZmZmODBiY2MwYTRjND5dIHN3YXBfZm4rMHgxYjgNCiAgICBbPGZmZmZm
ZjgwYmNhYzJlODg+XSBwcm9jZXNzX29uZV93b3JrKzB4MTY4DQogICAgWzxmZmZmZmY4MGJjYWMz
M2EwPl0gd29ya2VyX3RocmVhZCsweDIyNA0KICAgIFs8ZmZmZmZmODBiY2FjOTg2ND5dIGt0aHJl
YWQrMHhlMA0KICAgIFs8ZmZmZmZmODBiY2E4MzZlMD5dIHJldF9mcm9tX2ZvcmsrMHgxMA0KIA0K
VEFTSyBCOg0KWzUzNTQ3OC43MjQyNDldIENQVTogMyBQSUQ6IDQ2NDUgQ29tbTogQXVkaW9UcmFj
ayBUYWludGVkOiBHRiAgICBVRCBXICBPIDQuOS44Mi1wZXJmKyAjMQ0KWzUzNTQ3OC43MjQzODVd
IEhhcmR3YXJlIG5hbWU6IFF1YWxjb21tIFRlY2hub2xvZ2llcywgSW5jLiBTRE00NTAgUE1JNjMy
IE1UUCBTMyAoRFQpDQpbNTM1NDc4LjcyNDQ3OV0gdGFzazogZmZmZmZmYzAyNmNlMmEwMCB0YXNr
LnN0YWNrOiBmZmZmZmZjMDEyZTE0MDAwDQpbNTM1NDc4LjcyNDUzN10gUEMgaXMgYXQgX19yZWFk
X3N3YXBfY2FjaGVfYXN5bmMrMHgxNTQvMHgyNWMNCls1MzU0NzguNzI0NjMwXSBMUiBpcyBhdCBf
X3JlYWRfc3dhcF9jYWNoZV9hc3luYysweDljLzB4MjVjDQouLi4NCls1MzU0NzguNzM1NTQ2XSBb
PGZmZmZmZjgwYmNiZjk5NzA+XSBfX3JlYWRfc3dhcF9jYWNoZV9hc3luYysweDE1NC8weDI1Yw0K
WzUzNTQ3OC43MzU1OTldIFs8ZmZmZmZmODBiY2JmOWE5OD5dIHJlYWRfc3dhcF9jYWNoZV9hc3lu
YysweDIwLzB4NTQNCls1MzU0NzguNzM1Njk3XSBbPGZmZmZmZjgwYmNiZjliMjQ+XSBzd2FwaW5f
cmVhZGFoZWFkKzB4NTgvMHgyMTgNCls1MzU0NzguNzM1Nzk3XSBbPGZmZmZmZjgwYmNiZTUyNDA+
XSBkb19zd2FwX3BhZ2UrMHgzYzQvMHg0ZDANCls1MzU0NzguNzM1ODUwXSBbPGZmZmZmZjgwYmNi
ZTZiZjg+XSBoYW5kbGVfbW1fZmF1bHQrMHgzNjQvMHhiYTQNCls1MzU0NzguNzM1OTQ5XSBbPGZm
ZmZmZjgwYmNhOWI1YTg+XSBkb19wYWdlX2ZhdWx0KzB4MmEwLzB4MzhjDQpbNTM1NDc4LjczNjAw
M10gWzxmZmZmZmY4MGJjYTliNzljPl0gZG9fdHJhbnNsYXRpb25fZmF1bHQrMHg0MC8weDQ4DQpb
NTM1NDc4LjczNjEwMF0gWzxmZmZmZmY4MGJjYTgxMzQwPl0gZG9fbWVtX2Fib3J0KzB4NTAvMHhj
OA0KIA0KQ2hhbmdlLUlkOiBJMzZkOWRmN2NjZmY3N2M1ODliNzE1NzIyNTQxMDI2OWM2NzVhODUw
NA0KU2lnbmVkLW9mZi1ieTogemhhb3d1eXVuIDx6aGFvd3V5dW5Ad2luZ3RlY2guY29tPg0KLS0t
DQptbS92bXNjYW4uYyB8IDkgKysrKysrKysrDQoxIGZpbGUgY2hhbmdlZCwgOSBpbnNlcnRpb25z
KCspDQogDQpkaWZmIC0tZ2l0IGEvbW0vdm1zY2FuLmMgYi9tbS92bXNjYW4uYw0KaW5kZXggMjc0
MDk3My4uYWNlZGUwMDIgMTAwNjQ0DQotLS0gYS9tbS92bXNjYW4uYw0KKysrIGIvbW0vdm1zY2Fu
LmMNCkBAIC02NzQsNiArNjc0LDEyIEBAIHN0YXRpYyBpbnQgX19yZW1vdmVfbWFwcGluZyhzdHJ1
Y3QgYWRkcmVzc19zcGFjZSAqbWFwcGluZywgc3RydWN0IHBhZ2UgKnBhZ2UsDQpCVUdfT04oIVBh
Z2VMb2NrZWQocGFnZSkpOw0KQlVHX09OKG1hcHBpbmcgIT0gcGFnZV9tYXBwaW5nKHBhZ2UpKTsN
CisgLyoNCisgKiBwcmVlbXB0aW9uIG11c3QgYmUgZGlzYWJsZWQgdG8gcHJvdGVjdCBjdXJyZW50
IHRhc2sgcHJlZW1wdGVkIGJlZm9yZQ0KKyAqIHN3YXBjYWNoZV9mcmVlKHN3YXApIGludm9rZWQg
YnkgdGhlIHRhc2sgd2hpY2ggZG8gdGhlDQorICogX19yZWFkX3N3YXBfY2FjaGVfYXN5bmMgam9i
IG9uIHRoZSBzYW1lIHBhZ2UNCisgKi8NCisgcHJlZW1wdF9kaXNhYmxlKCk7DQpzcGluX2xvY2tf
aXJxc2F2ZSgmbWFwcGluZy0+dHJlZV9sb2NrLCBmbGFncyk7DQovKg0KKiBUaGUgbm9uIHJhY3kg
Y2hlY2sgZm9yIGEgYnVzeSBwYWdlLg0KQEAgLTcxNCw2ICs3MjAsNyBAQCBzdGF0aWMgaW50IF9f
cmVtb3ZlX21hcHBpbmcoc3RydWN0IGFkZHJlc3Nfc3BhY2UgKm1hcHBpbmcsIHN0cnVjdCBwYWdl
ICpwYWdlLA0KX19kZWxldGVfZnJvbV9zd2FwX2NhY2hlKHBhZ2UpOw0Kc3Bpbl91bmxvY2tfaXJx
cmVzdG9yZSgmbWFwcGluZy0+dHJlZV9sb2NrLCBmbGFncyk7DQpzd2FwY2FjaGVfZnJlZShzd2Fw
KTsNCisgcHJlZW1wdF9lbmFibGUoKTsNCn0gZWxzZSB7DQp2b2lkICgqZnJlZXBhZ2UpKHN0cnVj
dCBwYWdlICopOw0Kdm9pZCAqc2hhZG93ID0gTlVMTDsNCkBAIC03NDAsNiArNzQ3LDcgQEAgc3Rh
dGljIGludCBfX3JlbW92ZV9tYXBwaW5nKHN0cnVjdCBhZGRyZXNzX3NwYWNlICptYXBwaW5nLCBz
dHJ1Y3QgcGFnZSAqcGFnZSwNCnNoYWRvdyA9IHdvcmtpbmdzZXRfZXZpY3Rpb24obWFwcGluZywg
cGFnZSk7DQpfX2RlbGV0ZV9mcm9tX3BhZ2VfY2FjaGUocGFnZSwgc2hhZG93KTsNCnNwaW5fdW5s
b2NrX2lycXJlc3RvcmUoJm1hcHBpbmctPnRyZWVfbG9jaywgZmxhZ3MpOw0KKyBwcmVlbXB0X2Vu
YWJsZSgpOw0KaWYgKGZyZWVwYWdlICE9IE5VTEwpDQpmcmVlcGFnZShwYWdlKTsNCkBAIC03NDks
NiArNzU3LDcgQEAgc3RhdGljIGludCBfX3JlbW92ZV9tYXBwaW5nKHN0cnVjdCBhZGRyZXNzX3Nw
YWNlICptYXBwaW5nLCBzdHJ1Y3QgcGFnZSAqcGFnZSwNCmNhbm5vdF9mcmVlOg0Kc3Bpbl91bmxv
Y2tfaXJxcmVzdG9yZSgmbWFwcGluZy0+dHJlZV9sb2NrLCBmbGFncyk7DQorIHByZWVtcHRfZW5h
YmxlKCk7DQpyZXR1cm4gMDsNCn0NCi0tIA0KMS45LjENCiANCg==

------=_001_NextPart513000047512_=----
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charse=
t=3Dus-ascii"><style>body { line-height: 1.5; }blockquote { margin-top: 0p=
x; margin-bottom: 0px; margin-left: 0.5em; }body { font-size: 10.5pt; font=
-family: ????; color: rgb(0, 0, 0); line-height: 1.5; }</style></head><bod=
y>=0A<div><span></span></div><blockquote style=3D"margin-Top: 0px; margin-=
Bottom: 0px; margin-Left: 0.5em"><div><span style=3D"font-size: 10.5pt; li=
ne-height: 1.5; background-color: transparent;">From: zhaowuyun &lt;zhaowu=
yun@wingtech.com&gt;</span></div>=0A<div>&nbsp;</div>=0A<div>issue is that=
 there are two processes A and B, A is kworker/u16:8</div>=0A<div>normal p=
riority, B is AudioTrack, RT priority, they are on the</div>=0A<div>same C=
PU 3.</div>=0A<div>&nbsp;</div>=0A<div>The task A preempted by task B in t=
he moment</div>=0A<div>after __delete_from_swap_cache(page) and before swa=
pcache_free(swap).</div>=0A<div>&nbsp;</div>=0A<div>The task B does __read=
_swap_cache_async in the do {} while loop, it</div>=0A<div>will never find=
 the page from swapper_space because the page is removed</div>=0A<div>by t=
he task A, and it will never sucessfully in swapcache_prepare because</div=
>=0A<div>the entry is EEXIST.</div>=0A<div>&nbsp;</div>=0A<div>The task B =
then stuck in the loop infinitely because it is a RT task,</div>=0A<div>no=
 one can preempt it.</div>=0A<div>&nbsp;</div>=0A<div>so need to disable p=
reemption until the swapcache_free executed.</div>=0A<div>&nbsp;</div>=0A<=
div>TASK A:</div>=0A<div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div>=0A<div>Process: kworker/u16:=
8, cpu: 3 pid: 20289 start: 0xffffffc0385f8e00</div>=0A<div>=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D</div>=0A<div>&nbsp;&nbsp;&nbsp; Task name: kworker/u16:8 pid: 20289 cp=
u: 3 start: ffffffc0385f8e00</div>=0A<div>&nbsp;&nbsp;&nbsp; state: 0x0 ex=
it_state: 0x0 stack base: 0xffffffc012ba0000 Prio: 120</div>=0A<div>&nbsp;=
&nbsp;&nbsp; Stack:</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bca861a4&=
gt;] __switch_to+0x90</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bd83edd=
c&gt;] __schedule+0x29c</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bd83f=
600&gt;] preempt_schedule_common+0x24</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt=
;ffffff80bd83f63c&gt;] preempt_schedule.part.169+0x1c</div>=0A<div>&nbsp;&=
nbsp;&nbsp; [&lt;ffffff80bd83f664&gt;] preempt_schedule+0x20</div>=0A<div>=
&nbsp;&nbsp;&nbsp; [&lt;ffffff80bd84396c&gt;] _raw_spin_unlock_irqrestore+=
0x40</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcbc4710&gt;] __remove_m=
apping+0x174</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcbc7698&gt;] sh=
rink_page_list+0x894</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcbc7d7c=
&gt;] reclaim_pages_from_list+0xc8</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ff=
ffff80bcc7b910&gt;] reclaim_pte_range+0x158</div>=0A<div>&nbsp;&nbsp;&nbsp=
; [&lt;ffffff80bcbf45d4&gt;] walk_pgd_range+0xd4</div>=0A<div>&nbsp;&nbsp;=
&nbsp; [&lt;ffffff80bcbf476c&gt;] walk_page_range+0x74</div>=0A<div>&nbsp;=
&nbsp;&nbsp; [&lt;ffffff80bcc7cd64&gt;] reclaim_task_anon+0xdc</div>=0A<di=
v>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcc0a4c4&gt;] swap_fn+0x1b8</div>=0A<div=
>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcac2e88&gt;] process_one_work+0x168</div=
>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcac33a0&gt;] worker_thread+0x224=
</div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bcac9864&gt;] kthread+0xe0</=
div>=0A<div>&nbsp;&nbsp;&nbsp; [&lt;ffffff80bca836e0&gt;] ret_from_fork+0x=
10</div>=0A<div>&nbsp;</div>=0A<div>TASK B:</div>=0A<div>[535478.724249] C=
PU: 3 PID: 4645 Comm: AudioTrack Tainted: GF&nbsp;&nbsp;&nbsp; UD W&nbsp; =
O 4.9.82-perf+ #1</div>=0A<div>[535478.724385] Hardware name: Qualcomm Tec=
hnologies, Inc. SDM450 PMI632 MTP S3 (DT)</div>=0A<div>[535478.724479] tas=
k: ffffffc026ce2a00 task.stack: ffffffc012e14000</div>=0A<div>[535478.7245=
37] PC is at __read_swap_cache_async+0x154/0x25c</div>=0A<div>[535478.7246=
30] LR is at __read_swap_cache_async+0x9c/0x25c</div>=0A<div>...</div>=0A<=
div>[535478.735546] [&lt;ffffff80bcbf9970&gt;] __read_swap_cache_async+0x1=
54/0x25c</div>=0A<div>[535478.735599] [&lt;ffffff80bcbf9a98&gt;] read_swap=
_cache_async+0x20/0x54</div>=0A<div>[535478.735697] [&lt;ffffff80bcbf9b24&=
gt;] swapin_readahead+0x58/0x218</div>=0A<div>[535478.735797] [&lt;ffffff8=
0bcbe5240&gt;] do_swap_page+0x3c4/0x4d0</div>=0A<div>[535478.735850] [&lt;=
ffffff80bcbe6bf8&gt;] handle_mm_fault+0x364/0xba4</div>=0A<div>[535478.735=
949] [&lt;ffffff80bca9b5a8&gt;] do_page_fault+0x2a0/0x38c</div>=0A<div>[53=
5478.736003] [&lt;ffffff80bca9b79c&gt;] do_translation_fault+0x40/0x48</di=
v>=0A<div>[535478.736100] [&lt;ffffff80bca81340&gt;] do_mem_abort+0x50/0xc=
8</div>=0A<div>&nbsp;</div>=0A<div>Change-Id: I36d9df7ccff77c589b715722541=
0269c675a8504</div>=0A<div>Signed-off-by: zhaowuyun &lt;zhaowuyun@wingtech=
.com&gt;</div>=0A<div>---</div>=0A<div> mm/vmscan.c | 9 +++++++++</div>=0A=
<div> 1 file changed, 9 insertions(+)</div>=0A<div>&nbsp;</div>=0A<div>dif=
f --git a/mm/vmscan.c b/mm/vmscan.c</div>=0A<div>index 2740973..acede002 1=
00644</div>=0A<div>--- a/mm/vmscan.c</div>=0A<div>+++ b/mm/vmscan.c</div>=
=0A<div>@@ -674,6 +674,12 @@ static int __remove_mapping(struct address_sp=
ace *mapping, struct page *page,</div>=0A<div> 	BUG_ON(!PageLocked(page));=
</div>=0A<div> 	BUG_ON(mapping !=3D page_mapping(page));</div>=0A<div> </d=
iv>=0A<div>+	/*</div>=0A<div>+	 * preemption must be disabled to protect c=
urrent task preempted before</div>=0A<div>+	 * swapcache_free(swap) invoke=
d by the task which do the</div>=0A<div>+	 * __read_swap_cache_async job o=
n the same page</div>=0A<div>+	 */</div>=0A<div>+	preempt_disable();</div>=
=0A<div> 	spin_lock_irqsave(&amp;mapping-&gt;tree_lock, flags);</div>=0A<d=
iv> 	/*</div>=0A<div> 	 * The non racy check for a busy page.</div>=0A<div=
>@@ -714,6 +720,7 @@ static int __remove_mapping(struct address_space *map=
ping, struct page *page,</div>=0A<div> 		__delete_from_swap_cache(page);</=
div>=0A<div> 		spin_unlock_irqrestore(&amp;mapping-&gt;tree_lock, flags);<=
/div>=0A<div> 		swapcache_free(swap);</div>=0A<div>+		preempt_enable();</d=
iv>=0A<div> 	} else {</div>=0A<div> 		void (*freepage)(struct page *);</di=
v>=0A<div> 		void *shadow =3D NULL;</div>=0A<div>@@ -740,6 +747,7 @@ stati=
c int __remove_mapping(struct address_space *mapping, struct page *page,</=
div>=0A<div> 			shadow =3D workingset_eviction(mapping, page);</div>=0A<di=
v> 		__delete_from_page_cache(page, shadow);</div>=0A<div> 		spin_unlock_i=
rqrestore(&amp;mapping-&gt;tree_lock, flags);</div>=0A<div>+		preempt_enab=
le();</div>=0A<div> </div>=0A<div> 		if (freepage !=3D NULL)</div>=0A<div>=
 			freepage(page);</div>=0A<div>@@ -749,6 +757,7 @@ static int __remove_m=
apping(struct address_space *mapping, struct page *page,</div>=0A<div> </d=
iv>=0A<div> cannot_free:</div>=0A<div> 	spin_unlock_irqrestore(&amp;mappin=
g-&gt;tree_lock, flags);</div>=0A<div>+	preempt_enable();</div>=0A<div> 	r=
eturn 0;</div>=0A<div> }</div>=0A<div> </div>=0A<div>-- </div>=0A<div>1.9.=
1</div>=0A<div>&nbsp;</div>=0A</blockquote>=0A</body></html>
------=_001_NextPart513000047512_=------
