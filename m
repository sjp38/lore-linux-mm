Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 558546B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:05:34 -0400 (EDT)
From: Fanhenglong <fanhenglong@huawei.com>
Subject: PROBLEM: Kernel oops -- IP: [<ffffffff800cddfa>] kfree+0x5a/0x200
Date: Tue, 9 Apr 2013 09:04:49 +0000
Message-ID: <7EE47F9F3BEC294493BA3E433F16E08A242BFD4A@szxeml539-mbx.china.huawei.com>
Content-Language: zh-CN
Content-Type: multipart/alternative;
	boundary="_000_7EE47F9F3BEC294493BA3E433F16E08A242BFD4Aszxeml539mbxchi_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Xuzhichuang <xuzhichuang@huawei.com>

--_000_7EE47F9F3BEC294493BA3E433F16E08A242BFD4Aszxeml539mbxchi_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

SGksDQoNCkZ1bGwgZGVzY3JpcHRpb24gb2YgdGhlIHByb2JsZW06DQoNCktlcm5lbCB2ZXJzaW9u
OiAyLjYuMzIuMzYNCg0KT29wcyBpbmZvcm1hdGlvbjoNCg0KWzk2MzgyNzEuNjk1NjYzXSBCVUc6
IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IDAwMDAwMDAwMDBhM2Fk
OTANCls5NjM4MjcxLjY5NTY4NV0gSVA6IFs8ZmZmZmZmZmY4MDBjZGRmYT5dIGtmcmVlKzB4NWEv
MHgyMDANCls5NjM4MjcxLjY5NTcwMV0gUEdEIGY5NGZmMDY3IFBVRCBmZDY1MjA2NyBQTUQgMA0K
Wzk2MzgyNzEuNjk1NzA3XSBPb3BzOiAwMDAwIFsjMV0gU01QDQpbOTYzODI3MS42OTU3MTJdIGxh
c3Qgc3lzZnMgZmlsZTogL3N5cy9kZXZpY2VzL3hlbi1iYWNrZW5kL3ZiZC00MTUtNTE3NzYvc3Rh
dGlzdGljcy93cl9zZWN0DQoNClRyYXAgbnVtYmVyOjE0LCBtZXNzYWdlOk9vcHMNCkVycm9yIG51
bTogMA0KU2lnYWwgTnVtOjExX1NJR1NFR1YNCkV2ZW50IElEOkRJRV9PT1BTDQpSSVA6IGUwMzA6
WzxmZmZmZmZmZjgwMGNkZGZhPl0NCjxmZmZmZmZmZjgwMGNkZGZhPntrZnJlZSsweDVhfQ0KUlNQ
OiBlMDJiOmZmZmY4ODAwMWNlNjVkYTggIEVGTEFHUzogMDAwMTAwMDYNClJBWDogMDAwMDAwMDAw
MGEzYWQ5MCBSQlg6IDAwMDAwMDAwMDAwMDAwMDAgUkNYOiAwMDAwMDAwMDAwMDAwMmViDQpSRFg6
IDAwMDAwMDAwMDAxNzYxZjAgUlNJOiAwMDAwMDAwMDAwMDAwMmViIFJESTogZmZmZjg4MDAyZWMz
ZTNlMA0KUkJQOiBmZmZmZmZmZmZmZmZmZmZlIFIwODogMDAwMDAwMDAwMDAwMDAwMCBSMDk6IGZm
ZmY4ODAwMmVjM2UzZTANClIxMDogZmZmZmZmZmZmZmZmZmZmZiBSMTE6IGZmZmZmZmZmODAxYjBl
NTAgUjEyOiAwMDAwMDAwMDAwMDA4MDAxDQpSMTM6IDAwMDAwMDAwMDAwMDAwMjQgUjE0OiAwMDAw
MDAwMGZmZmZmZjljIFIxNTogZmZmZjg4MDAxY2U2NWU0OA0KRlM6ICAwMDAwN2ZiZTA1ZTcxNzAw
KDAwMDApIEdTOmZmZmY4ODAwMDIwMDgwMDAoMDAwMCkga25sR1M6MDAwMDAwMDAwMDAwMDAwMA0K
Q1M6ICBlMDMzIERTOiAwMDAwIEVTOiAwMDAwIENSMDogMDAwMDAwMDA4MDA1MDAzMw0KQ1IyOiAw
MDAwMDAwMDAwYTNhZDkwIENSMzogMDAwMDAwMDBmOTAwOTAwMCBDUjQ6IDAwMDAwMDAwMDAwMDI2
MjANCkRSMDogMDAwMDAwMDAwMDAwMDAwMCBEUjE6IDAwMDAwMDAwMDAwMDAwMDAgRFIyOiAwMDAw
MDAwMDAwMDAwMDAwDQpEUjM6IDAwMDAwMDAwMDAwMDAwMDAgRFI2OiAwMDAwMDAwMGZmZmYwZmYw
IERSNzogMDAwMDAwMDAwMDAwMDQwMA0KPGtlcm5lbF90cmFjZT4NCiAgICAgICA8ZmZmZmZmZmY4
MDAwOWIwNT57ZHVtcF90cmFjZSsweDY1fQ0KICAgICAgIDxmZmZmZmZmZjgwMzdkODk3Pntub3Rp
Zmllcl9jYWxsX2NoYWluKzB4Mzd9DQogICAgICAgPGZmZmZmZmZmODAwNWExZWQ+e25vdGlmeV9k
aWUrMHgyZH0NCiAgICAgICA8ZmZmZmZmZmY4MDM3YmQwYj57X19kaWUrMHg4Yn0NCiAgICAgICA8
ZmZmZmZmZmY4MDAxYmVkMT57bm9fY29udGV4dCsweGQxfQ0KICAgICAgIDxmZmZmZmZmZjgwMDFj
MWY1PntfX2JhZF9hcmVhX25vc2VtYXBob3JlKzB4MTc1fQ0KICAgICAgIDxmZmZmZmZmZjgwMzdi
Mjk4PntwYWdlX2ZhdWx0KzB4Mjh9DQogICAgICAgPGZmZmZmZmZmODAwY2RkZmE+e2tmcmVlKzB4
NWF9DQogICAgICAgPGZmZmZmZmZmODAwZGEwM2Q+e3B1dF9maWxwKzB4MWR9DQogICAgICAgPGZm
ZmZmZmZmODAwZTcxMzM+e2RvX2ZpbHBfb3BlbisweDcyM30NCiAgICAgICA8ZmZmZmZmZmY4MDBk
NjJiNz57ZG9fc3lzX29wZW4rMHg5N30NCiAgICAgICA8ZmZmZmZmZmY4MDAwNzM3OD57c3lzdGVt
X2NhbGxfZmFzdHBhdGgrMHgxNn0NCiAgICAgICBbPDAwMDA3ZmJlMDU5YzgwNDA+XQ0KPC9rZXJu
ZWxfdHJhY2U+DQoNCkZvbGxvd2luZyBpcyBteSBvd24gcHJlbGltaW5hcnkgYW5hbHlzaXM6DQoN
CmNyYXNoPiBkaXMga2ZyZWUNCjB4ZmZmZmZmZmY4MDBjZGRhMCA8a2ZyZWU+OiAgICAgcHVzaCAg
ICVyMTUNCjB4ZmZmZmZmZmY4MDBjZGRhMiA8a2ZyZWUrMj46ICAgcHVzaCAgICVyMTQNCjB4ZmZm
ZmZmZmY4MDBjZGRhNCA8a2ZyZWUrND46ICAgcHVzaCAgICVyMTMNCjB4ZmZmZmZmZmY4MDBjZGRh
NiA8a2ZyZWUrNj46ICAgcHVzaCAgICVyMTINCjB4ZmZmZmZmZmY4MDBjZGRhOCA8a2ZyZWUrOD46
ICAgcHVzaCAgICVyYnANCjB4ZmZmZmZmZmY4MDBjZGRhOSA8a2ZyZWUrOT46ICAgcHVzaCAgICVy
YngNCjB4ZmZmZmZmZmY4MDBjZGRhYSA8a2ZyZWUrMTA+OiAgc3ViICAgICQweDE4LCVyc3ANCjB4
ZmZmZmZmZmY4MDBjZGRhZSA8a2ZyZWUrMTQ+OiAgY21wICAgICQweDEwLCVyZGkNCjB4ZmZmZmZm
ZmY4MDBjZGRiMiA8a2ZyZWUrMTg+OiAgbW92ICAgICVyZGksMHg4KCVyc3ApDQoweGZmZmZmZmZm
ODAwY2RkYjcgPGtmcmVlKzIzPjogIGpiZSAgICAweGZmZmZmZmZmODAwY2RlN2MgPGtmcmVlKzIy
MD4NCjB4ZmZmZmZmZmY4MDBjZGRiZCA8a2ZyZWUrMjk+OiAgbW92ICAgICVnczoweDY3YzEsJWFs
DQoweGZmZmZmZmZmODAwY2RkYzUgPGtmcmVlKzM3PjogIG1vdmIgICAkMHgxLCVnczoweDY3YzEN
CjB4ZmZmZmZmZmY4MDBjZGRjZSA8a2ZyZWUrNDY+OiAgbW92ICAgICVhbCwweDE3KCVyc3ApDQow
eGZmZmZmZmZmODAwY2RkZDIgPGtmcmVlKzUwPjogIG1vdiAgICAweDgoJXJzcCksJXJkaQ0KMHhm
ZmZmZmZmZjgwMGNkZGQ3IDxrZnJlZSs1NT46ICBtb3YgICAgMHg3NTg4NzIoJXJpcCksJXJieCAg
ICAgICAgIyAweGZmZmZmZmZmODA4MjY2NTANCjB4ZmZmZmZmZmY4MDBjZGRkZSA8a2ZyZWUrNjI+
OiAgY2FsbHEgIDB4ZmZmZmZmZmY4MDAyMjhlMCA8X19waHlzX2FkZHI+DQoweGZmZmZmZmZmODAw
Y2RkZTMgPGtmcmVlKzY3PjogIHNociAgICAkMHhjLCVyYXgNCjB4ZmZmZmZmZmY4MDBjZGRlNyA8
a2ZyZWUrNzE+OiAgbGVhICAgIDB4MCgsJXJheCw4KSwlcmR4DQoweGZmZmZmZmZmODAwY2RkZWYg
PGtmcmVlKzc5PjogIHNobCAgICAkMHg2LCVyYXgNCjB4ZmZmZmZmZmY4MDBjZGRmMyA8a2ZyZWUr
ODM+OiAgc3ViICAgICVyZHgsJXJheA0KMHhmZmZmZmZmZjgwMGNkZGY2IDxrZnJlZSs4Nj46ICBs
ZWEgICAgKCVyYngsJXJheCwxKSwlcmF4DQoweGZmZmZmZmZmODAwY2RkZmEgPGtmcmVlKzkwPjog
IG1vdiAgICAoJXJheCksJXJkeA0KMHhmZmZmZmZmZjgwMGNkZGZkIDxrZnJlZSs5Mz46ICB0ZXN0
ICAgJDB4MjAwMDAsJWVkeA0KMHhmZmZmZmZmZjgwMGNkZTAzIDxrZnJlZSs5OT46ICBqZSAgICAg
MHhmZmZmZmZmZjgwMGNkZTFiIDxrZnJlZSsxMjM+DQoweGZmZmZmZmZmODAwY2RlMDUgPGtmcmVl
KzEwMT46IG1vdiAgICAweDEwKCVyYXgpLCVyYXgNCjB4ZmZmZmZmZmY4MDBjZGUwOSA8a2ZyZWUr
MTA1PjogbW92ICAgICglcmF4KSwlcmR4DQoweGZmZmZmZmZmODAwY2RlMGMgPGtmcmVlKzEwOD46
IHRlc3QgICAkMHgyMDAwMCwlZWR4DQoweGZmZmZmZmZmODAwY2RlMTIgPGtmcmVlKzExND46IGpl
ICAgICAweGZmZmZmZmZmODAwY2RlMWIgPGtmcmVlKzEyMz4NCi4uLi4uLg0KDQpOb3JtYWxseSAl
cmJ4IHNob3VsZCBiZSB0aGUgdmFsdWUgb2YgbWVtX21hcCB3aGljaCBpcyBhIGZpeGVkIHZhbHVl
IGluIG15IHN5c3RlbSwgdGhlIGFkZHJlc3Mgb2YgdGhlIG1lbV9tYXAgaXMgMHhmZmZmZmZmZjgw
ODI2NjUwLCBhbmQgdGhlIHZhbHVlIG9mIG1lbV9tYXAgaXMgMHhmZmZmODgwMDA0ODAyMDAwLg0K
DQpCdXQgaGVyZSwgJXJieCB3YXMgY2hhbmdlZCB0byAweDAwMDAwMDAwMDAwMDAwMDAsIGluIG15
IG9waW5pb24sIHRoZSBwb3NzaWJsZSByZWFzb24gaXMgYmVsb3c6DQoNCjEuIG1lbV9tYXAgd2Fz
IGNoYW5nZWQgd2l0aCBhbiB1bmtub3duIHJlYXNvbiwgbGVkIHRvICVyYnggaXMgd3JvbmcuDQoy
LiBtZW1fbWFwIGlzIHJpZ2h0LCBidXQgJXJpcCBpcyB3cm9uZywgbGVkIHRvICVyYnggaXMgd3Jv
bmcuDQozLiBtZW1fbWFwIGlzIHJpZ2h0LCBhbmQgJXJpcCBpcyBhbHNvIHJpZ2h0LCBidXQgJXJi
eCB3YXMgY2hhbmdlZCBhZnRlciBsYXRlci4NCg0KSSBjaGFuZ2VkIHRoZSBtZW1fbWFwIHZhbHVl
IHRvIDB4MDAwMDAwMDAwMDAwMDAwMCwga2VybmVsIGlzIHBhbmljIGltbWVkaWF0ZWx5LCBidXQg
aXQgY2Fuoa90IHByb2R1Y2UgdGhlIHZtY29yZSwgdGhpcyBwcm9ibGVtIGhhcyB0aGUgdm1jb3Jl
KHNhZCB0byBzYXksIHZtY29yZSB3YXMgZ29uZSBiZWNhdXNlIG9mIGNhcmVsZXNzbmVzcykuDQoN
ClNvIHdlIGNhbiBleGNsdWRlIHRoZSByZWFzb24gb25lLCB0aGUgcmVzdCBvZiB0aGUgcmVhc29u
IGlzIHR3byBhbmQgdGhyZWUsIGJ1dCBpIGRvbqGvdCBrbm93IGhvdyB0aGV5IGNhbiBoYXBwZW4u
DQoNCkkgZG9uJ3QgZG8gYW55dGhpbmcgYmVmb3JlIHRoZSBzeXN0ZW0gcGFuaWMsIGFuZCBpIGNh
bqGvdCByZXByb2R1Y2UgdGhpcyBwcm9ibGVtLg0KDQoNCg==

--_000_7EE47F9F3BEC294493BA3E433F16E08A242BFD4Aszxeml539mbxchi_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html dir=3D"ltr">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<meta name=3D"GENERATOR" content=3D"MSHTML 8.00.7600.17185">
<style id=3D"owaParaStyle">P {
	MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px
}
</style>
</head>
<body fPStyle=3D"1" ocsi=3D"0">
<div style=3D"direction: ltr;font-family: Tahoma;color: #000000;font-size: =
10pt;">
<p>Hi,</p>
<p>Full description of the problem:</p>
<p>Kernel version: 2.6.32.36</p>
<p>Oops information:</p>
<p>[9638271.695663] BUG: unable to handle kernel paging request at 00000000=
00a3ad90<br>
[9638271.695685] IP: [&lt;ffffffff800cddfa&gt;] kfree&#43;0x5a/0x200<br>
[9638271.695701] PGD f94ff067 PUD fd652067 PMD 0 <br>
[9638271.695707] Oops: 0000 [#1] SMP<br>
[9638271.695712] last sysfs file: /sys/devices/xen-backend/vbd-415-51776/st=
atistics/wr_sect</p>
<p>Trap number:14, message:Oops<br>
Error num: 0<br>
Sigal Num:11_SIGSEGV<br>
Event ID:DIE_OOPS<br>
RIP: e030:[&lt;ffffffff800cddfa&gt;]<br>
&lt;ffffffff800cddfa&gt;{kfree&#43;0x5a}<br>
RSP: e02b:ffff88001ce65da8&nbsp; EFLAGS: 00010006<br>
RAX: 0000000000a3ad90 RBX: 0000000000000000 RCX: 00000000000002eb<br>
RDX: 00000000001761f0 RSI: 00000000000002eb RDI: ffff88002ec3e3e0<br>
RBP: fffffffffffffffe R08: 0000000000000000 R09: ffff88002ec3e3e0<br>
R10: ffffffffffffffff R11: ffffffff801b0e50 R12: 0000000000008001<br>
R13: 0000000000000024 R14: 00000000ffffff9c R15: ffff88001ce65e48<br>
FS:&nbsp; 00007fbe05e71700(0000) GS:ffff880002008000(0000) knlGS:0000000000=
000000<br>
CS:&nbsp; e033 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
CR2: 0000000000a3ad90 CR3: 00000000f9009000 CR4: 0000000000002620<br>
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000<br>
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400<br>
&lt;kernel_trace&gt;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff80009b05&gt;{dump_trace&#4=
3;0x65}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff8037d897&gt;{notifier_call=
_chain&#43;0x37}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff8005a1ed&gt;{notify_die&#4=
3;0x2d}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff8037bd0b&gt;{__die&#43;0x8=
b}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff8001bed1&gt;{no_context&#4=
3;0xd1}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff8001c1f5&gt;{__bad_area_no=
semaphore&#43;0x175}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff8037b298&gt;{page_fault&#4=
3;0x28}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff800cddfa&gt;{kfree&#43;0x5=
a}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff800da03d&gt;{put_filp&#43;=
0x1d}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff800e7133&gt;{do_filp_open&=
#43;0x723}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff800d62b7&gt;{do_sys_open&#=
43;0x97}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ffffffff80007378&gt;{system_call_f=
astpath&#43;0x16}<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [&lt;00007fbe059c8040&gt;]<br>
&lt;/kernel_trace&gt;</p>
<p><br>
Following is my own preliminary analysis:</p>
<p>crash&gt; dis kfree<br>
0xffffffff800cdda0 &lt;kfree&gt;:&nbsp;&nbsp;&nbsp;&nbsp; push&nbsp;&nbsp; =
%r15<br>
0xffffffff800cdda2 &lt;kfree&#43;2&gt;:&nbsp;&nbsp; push&nbsp;&nbsp; %r14<b=
r>
0xffffffff800cdda4 &lt;kfree&#43;4&gt;:&nbsp;&nbsp; push&nbsp;&nbsp; %r13<b=
r>
0xffffffff800cdda6 &lt;kfree&#43;6&gt;:&nbsp;&nbsp; push&nbsp;&nbsp; %r12<b=
r>
0xffffffff800cdda8 &lt;kfree&#43;8&gt;:&nbsp;&nbsp; push&nbsp;&nbsp; %rbp<b=
r>
0xffffffff800cdda9 &lt;kfree&#43;9&gt;:&nbsp;&nbsp; push&nbsp;&nbsp; %rbx<b=
r>
0xffffffff800cddaa &lt;kfree&#43;10&gt;:&nbsp; sub&nbsp;&nbsp;&nbsp; $0x18,=
%rsp<br>
0xffffffff800cddae &lt;kfree&#43;14&gt;:&nbsp; cmp&nbsp;&nbsp;&nbsp; $0x10,=
%rdi<br>
0xffffffff800cddb2 &lt;kfree&#43;18&gt;:&nbsp; mov&nbsp;&nbsp;&nbsp; %rdi,0=
x8(%rsp)<br>
0xffffffff800cddb7 &lt;kfree&#43;23&gt;:&nbsp; jbe&nbsp;&nbsp;&nbsp; 0xffff=
ffff800cde7c &lt;kfree&#43;220&gt;<br>
0xffffffff800cddbd &lt;kfree&#43;29&gt;:&nbsp; mov&nbsp;&nbsp;&nbsp; %gs:0x=
67c1,%al<br>
0xffffffff800cddc5 &lt;kfree&#43;37&gt;:&nbsp; movb&nbsp;&nbsp; $0x1,%gs:0x=
67c1<br>
0xffffffff800cddce &lt;kfree&#43;46&gt;:&nbsp; mov&nbsp;&nbsp;&nbsp; %al,0x=
17(%rsp)<br>
0xffffffff800cddd2 &lt;kfree&#43;50&gt;:&nbsp; mov&nbsp;&nbsp;&nbsp; 0x8(%r=
sp),%rdi<br>
0xffffffff800cddd7 &lt;kfree&#43;55&gt;:&nbsp; mov&nbsp;&nbsp;&nbsp; 0x7588=
72(%rip),%rbx&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # 0xffffffff8082665=
0<br>
0xffffffff800cddde &lt;kfree&#43;62&gt;:&nbsp; callq&nbsp; 0xffffffff800228=
e0 &lt;__phys_addr&gt;<br>
0xffffffff800cdde3 &lt;kfree&#43;67&gt;:&nbsp; shr&nbsp;&nbsp;&nbsp; $0xc,%=
rax<br>
0xffffffff800cdde7 &lt;kfree&#43;71&gt;:&nbsp; lea&nbsp;&nbsp;&nbsp; 0x0(,%=
rax,8),%rdx<br>
0xffffffff800cddef &lt;kfree&#43;79&gt;:&nbsp; shl&nbsp;&nbsp;&nbsp; $0x6,%=
rax<br>
0xffffffff800cddf3 &lt;kfree&#43;83&gt;:&nbsp; sub&nbsp;&nbsp;&nbsp; %rdx,%=
rax<br>
0xffffffff800cddf6 &lt;kfree&#43;86&gt;:&nbsp; lea&nbsp;&nbsp;&nbsp; (%rbx,=
%rax,1),%rax<br>
0xffffffff800cddfa &lt;kfree&#43;90&gt;:&nbsp; mov&nbsp;&nbsp;&nbsp; (%rax)=
,%rdx<br>
0xffffffff800cddfd &lt;kfree&#43;93&gt;:&nbsp; test&nbsp;&nbsp; $0x20000,%e=
dx<br>
0xffffffff800cde03 &lt;kfree&#43;99&gt;:&nbsp; je&nbsp;&nbsp;&nbsp;&nbsp; 0=
xffffffff800cde1b &lt;kfree&#43;123&gt;<br>
0xffffffff800cde05 &lt;kfree&#43;101&gt;: mov&nbsp;&nbsp;&nbsp; 0x10(%rax),=
%rax<br>
0xffffffff800cde09 &lt;kfree&#43;105&gt;: mov&nbsp;&nbsp;&nbsp; (%rax),%rdx=
<br>
0xffffffff800cde0c &lt;kfree&#43;108&gt;: test&nbsp;&nbsp; $0x20000,%edx<br=
>
0xffffffff800cde12 &lt;kfree&#43;114&gt;: je&nbsp;&nbsp;&nbsp;&nbsp; 0xffff=
ffff800cde1b &lt;kfree&#43;123&gt;<br>
......</p>
<p>Normally %rbx should be the value of mem_map which is a fixed value in m=
y system, the address of the mem_map is 0xffffffff80826650, and the value o=
f mem_map is 0xffff880004802000.</p>
<p>But here, %rbx was changed to 0x0000000000000000, in my opinion, the pos=
sible reason is below:</p>
<p>1.&nbsp;mem_map was changed with an unknown reason, led to %rbx is wrong=
.<br>
2.&nbsp;mem_map is right, but %rip is wrong, led to %rbx is wrong.<br>
3.&nbsp;mem_map is right, and %rip is also right, but %rbx was changed afte=
r later.</p>
<p>I changed the mem_map value to 0x0000000000000000, kernel is panic immed=
iately, but it can=A1=AFt produce the vmcore, this problem has the vmcore(s=
ad to say, vmcore was gone because of carelessness).</p>
<p>So we can exclude the reason one, the rest of the reason is two and thre=
e, but i don=A1=AFt know how they can happen.</p>
<p>I don't do anything before the system panic, and i can=A1=AFt reproduce =
this problem.</p>
<p><br>
&nbsp;</p>
</div>
</body>
</html>

--_000_7EE47F9F3BEC294493BA3E433F16E08A242BFD4Aszxeml539mbxchi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
