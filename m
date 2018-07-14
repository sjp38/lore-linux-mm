Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D57FF6B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 09:40:09 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id a10-v6so983543itc.9
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 06:40:09 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f8-v6si8640261jam.30.2018.07.14.06.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jul 2018 06:40:08 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6EDdpci047420
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 13:40:07 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2k7a33rse0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 13:40:07 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6EDe6XB011344
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 13:40:06 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6EDe6Pp030604
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 13:40:06 GMT
Received: by mail-oi0-f49.google.com with SMTP id l10-v6so20417986oii.0
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 06:40:06 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
 <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
 <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com> <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com> <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
 <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com> <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
In-Reply-To: <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sat, 14 Jul 2018 09:39:29 -0400
Message-ID: <CAGM2reb2Zk6t=QJtJZPRGwovKKR9bdm+fzgmA_7CDVfDTjSgKA@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: multipart/mixed; boundary="000000000000edd2760570f5bbf9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Theodore Tso <tytso@google.com>, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

--000000000000edd2760570f5bbf9
Content-Type: text/plain; charset="UTF-8"

Hi Linus,

I attached a temporary fix, which I could not test, as I was unable to
reproduce the problem, but it should fix the issue.

Reverting "f7f99100d8d9 mm: stop zeroing memory during allocation in
vmemmap" would introduce a significant boot performance regression, as
we would zero the whole memmap twice during boot.

Later, I will introduce a more detailed fix that will get rid of
zero_resv_unavail() entirely, and instead will zero skipped struct
pages in memmap_init_zone(), where it should be done.

Thank you,
Pavel

On Fri, Jul 13, 2018 at 11:25 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Fri, Jul 13, 2018 at 8:04 PM Pavel Tatashin
> <pasha.tatashin@oracle.com> wrote:
> >
> > > You can't just memset() the 'struct page' to zero after it's been set up.
> >
> > That should not be happening, unless there is a bug.
>
> Well, it does seem to happen. My memory stress-tester has been running
> for about half an hour now with the revert I posted - it used to
> trigger the problem in maybe ~5 minutes before.
>
> So I do think that revert fixes it for me. No guarantees, but since I
> figured out how to trigger it, it's been fairly reliable.
>
> > We want to zero those struct pages so we do not have uninitialized
> > data accessed by various parts of the code that rounds down large
> > pages and access the first page in section without verifying that the
> > page is valid. The example of this is described in commit that
> > introduced zero_resv_unavail()
>
> I'm attaching the relevant (?) parts of dmesg, which has the node
> ranges, maybe you can see what the problem with the code is.
>
> (NOTE! This dmesg is with that "mem=6G" command line option, which causes that
>
>   e820: remove [mem 0x180000000-0xfffffffffffffffe] usable
>
> line - that's just because it's my stress-test boot. It happens with
> or without it, but without the "mem=6G" it took days to trigger).
>
> I'm more than willing to test patches (either for added information or
> for testing fixes), although I think I'm getting off the computer for
> today.
>
>                 Linus

--000000000000edd2760570f5bbf9
Content-Type: text/x-patch; charset="US-ASCII";
	name="0001-mm-zero-unavailable-pages-before-memmap-init.patch"
Content-Disposition: attachment;
	filename="0001-mm-zero-unavailable-pages-before-memmap-init.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jjlgjnjw0>
X-Attachment-Id: f_jjlgjnjw0

RnJvbSA5NTI1OTg0MWVmNzljYzE3YzczNGE5OTRhZmZhMzcxNDQ3OTc1M2UzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQYXZlbCBUYXRhc2hpbiA8cGFzaGEudGF0YXNoaW5Ab3JhY2xl
LmNvbT4KRGF0ZTogU2F0LCAxNCBKdWwgMjAxOCAwOToxNTowNyAtMDQwMApTdWJqZWN0OiBbUEFU
Q0hdIG1tOiB6ZXJvIHVuYXZhaWxhYmxlIHBhZ2VzIGJlZm9yZSBtZW1tYXAgaW5pdAoKV2UgbXVz
dCB6ZXJvIHN0cnVjdCBwYWdlcyBmb3IgbWVtb3J5IHRoYXQgaXMgbm90IGJhY2tlZCBieSBwaHlz
aWNhbCBtZW1vcnksCm9yIGtlcm5lbCBkb2VzIG5vdCBoYXZlIGFjY2VzcyB0by4KClJlY2VudGx5
LCB0aGVyZSB3YXMgYSBjaGFuZ2Ugd2hpY2ggemVyb2VkIGFsbCBtZW1tYXAgZm9yIGFsbCBob2xl
cyBpbiBlODIwLgpVbmZvcnR1bmF0ZWx5LCBpdCBpbnRyb2R1Y2VkIGEgYnVnIHRoYXQgaXMgZGlz
Y3Vzc2VkIGhlcmU6CgpodHRwczovL3d3dy5zcGluaWNzLm5ldC9saXN0cy9saW51eC1tbS9tc2cx
NTY3NjQuaHRtbAoKTGludXMsIGFsc28gc2F3IHRoaXMgYnVnIG9uIGhpcyBtYWNoaW5lLCBhbmQg
Y29uZmlybWVkIHRoYXQgcHVsbGluZwpjb21taXQgMTI0MDQ5ZGVjYmIxICgieDg2L2U4MjA6IHB1
dCAhRTgyMF9UWVBFX1JBTSByZWdpb25zIGludG8gbWVtYmxvY2sucmVzZXJ2ZWQiKQpmaXhlcyB0
aGUgaXNzdWUuCgpUaGUgcHJvYmxlbSBpcyB0aGF0IHdlIGluY29ycmVjdGx5IHplcm8gc29tZSBz
dHJ1Y3QgcGFnZXMgYWZ0ZXIgdGhleSB3ZXJlCnNldHVwLgoKVGhlIGZpeCBpcyB0byB6ZXJvIHVu
YXZhaWxhYmxlIHN0cnVjdCBwYWdlcyBwcmlvciB0byBpbml0aWFsaXppbmcgb2Ygc3RydWN0IHBh
Z2VzLgoKQSBtb3JlIGRldGFpbGVkIGZpeCBzaG91bGQgY29tZSBsYXRlciB0aGF0IHdvdWxkIGF2
b2lkIGRvdWJsZSB6ZXJvaW5nCmNhc2VzOiBvbmUgaW4gX19pbml0X3NpbmdsZV9wYWdlKCksIHRo
ZSBvdGhlciBvbmUgaW4gemVyb19yZXN2X3VuYXZhaWwoKS4KCkZpeGVzOiAxMjQwNDlkZWNiYjEg
KCJ4ODYvZTgyMDogcHV0ICFFODIwX1RZUEVfUkFNIHJlZ2lvbnMgaW50byBtZW1ibG9jay5yZXNl
cnZlZCIpCgpTaWduZWQtb2ZmLWJ5OiBQYXZlbCBUYXRhc2hpbiA8cGFzaGEudGF0YXNoaW5Ab3Jh
Y2xlLmNvbT4KLS0tCiBtbS9wYWdlX2FsbG9jLmMgfCA0ICsrLS0KIDEgZmlsZSBjaGFuZ2VkLCAy
IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vcGFnZV9hbGxv
Yy5jIGIvbW0vcGFnZV9hbGxvYy5jCmluZGV4IDE1MjExMDBmMWU2My4uNWQ4MDBkNjFkZGI3IDEw
MDY0NAotLS0gYS9tbS9wYWdlX2FsbG9jLmMKKysrIGIvbW0vcGFnZV9hbGxvYy5jCkBAIC02ODQ3
LDYgKzY4NDcsNyBAQCB2b2lkIF9faW5pdCBmcmVlX2FyZWFfaW5pdF9ub2Rlcyh1bnNpZ25lZCBs
b25nICptYXhfem9uZV9wZm4pCiAJLyogSW5pdGlhbGlzZSBldmVyeSBub2RlICovCiAJbW1pbml0
X3ZlcmlmeV9wYWdlZmxhZ3NfbGF5b3V0KCk7CiAJc2V0dXBfbnJfbm9kZV9pZHMoKTsKKwl6ZXJv
X3Jlc3ZfdW5hdmFpbCgpOwogCWZvcl9lYWNoX29ubGluZV9ub2RlKG5pZCkgewogCQlwZ19kYXRh
X3QgKnBnZGF0ID0gTk9ERV9EQVRBKG5pZCk7CiAJCWZyZWVfYXJlYV9pbml0X25vZGUobmlkLCBO
VUxMLApAQCAtNjg1Nyw3ICs2ODU4LDYgQEAgdm9pZCBfX2luaXQgZnJlZV9hcmVhX2luaXRfbm9k
ZXModW5zaWduZWQgbG9uZyAqbWF4X3pvbmVfcGZuKQogCQkJbm9kZV9zZXRfc3RhdGUobmlkLCBO
X01FTU9SWSk7CiAJCWNoZWNrX2Zvcl9tZW1vcnkocGdkYXQsIG5pZCk7CiAJfQotCXplcm9fcmVz
dl91bmF2YWlsKCk7CiB9CiAKIHN0YXRpYyBpbnQgX19pbml0IGNtZGxpbmVfcGFyc2VfY29yZShj
aGFyICpwLCB1bnNpZ25lZCBsb25nICpjb3JlLApAQCAtNzAzMyw5ICs3MDMzLDkgQEAgdm9pZCBf
X2luaXQgc2V0X2RtYV9yZXNlcnZlKHVuc2lnbmVkIGxvbmcgbmV3X2RtYV9yZXNlcnZlKQogCiB2
b2lkIF9faW5pdCBmcmVlX2FyZWFfaW5pdCh1bnNpZ25lZCBsb25nICp6b25lc19zaXplKQogewor
CXplcm9fcmVzdl91bmF2YWlsKCk7CiAJZnJlZV9hcmVhX2luaXRfbm9kZSgwLCB6b25lc19zaXpl
LAogCQkJX19wYShQQUdFX09GRlNFVCkgPj4gUEFHRV9TSElGVCwgTlVMTCk7Ci0JemVyb19yZXN2
X3VuYXZhaWwoKTsKIH0KIAogc3RhdGljIGludCBwYWdlX2FsbG9jX2NwdV9kZWFkKHVuc2lnbmVk
IGludCBjcHUpCi0tIAoyLjE4LjAKCg==
--000000000000edd2760570f5bbf9--
