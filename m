Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 133786B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 00:55:15 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so912160bkh.6
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 21:55:15 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id j6si1494448bko.280.2014.01.23.21.55.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 21:55:14 -0800 (PST)
Received: by mail-ig0-f170.google.com with SMTP id m12so4033426iga.1
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 21:55:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E19C7D.7050603@intel.com>
References: <52E19C7D.7050603@intel.com>
Date: Thu, 23 Jan 2014 21:55:13 -0800
Message-ID: <CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=f46d0443fddc64c84c04f0b100ee
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

--f46d0443fddc64c84c04f0b100ee
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jan 23, 2014 at 2:49 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> Linus's current tree doesn't boot on an 8-node/1TB NUMA system that I
> have.  Its reboots are *LONG*, so I haven't fully bisected it, but it's
> down to a just a few commits, most of which are changes to the memblock
> code.  Since the panic is in the memblock code, it looks like a
> no-brainer.  It's almost certainly the code from Santosh or Grygorii
> that's triggering this.
>
> Config and good/bad dmesg with memblock=debug are here:
>
>         http://sr71.net/~dave/intel/3.13/
>
> Please let me know if you need it bisected further than this.

Please check attached patch, and it should fix the problem.

Yinghai

--f46d0443fddc64c84c04f0b100ee
Content-Type: text/x-patch; charset=US-ASCII; name="fix_numa_x.patch"
Content-Disposition: attachment; filename="fix_numa_x.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hqt1cp030

U3ViamVjdDogW1BBVENIXSB4ODY6IEZpeCBudW1hIHdpdGggcmV2ZXJ0aW5nIHdyb25nIG1lbWJs
b2NrIHNldHRpbmcuCgpEYXZlIHJlcG9ydGVkIE51bWEgb24geDg2IGlzIGJyb2tlbiBvbiBzeXN0
ZW0gd2l0aCAxVCBtZW1vcnkuCgpJdCB0dXJucyBvdXQKfCBjb21taXQgNWI2ZTUyOTUyMWQzNWUx
YmNhYTBmZTQzNDU2ZDFiYmIzMzVjYWU1ZAp8IEF1dGhvcjogU2FudG9zaCBTaGlsaW1rYXIgPHNh
bnRvc2guc2hpbGlta2FyQHRpLmNvbT4KfCBEYXRlOiAgIFR1ZSBKYW4gMjEgMTU6NTA6MDMgMjAx
NCAtMDgwMAp8CnwgICAgeDg2OiBtZW1ibG9jazogc2V0IGN1cnJlbnQgbGltaXQgdG8gbWF4IGxv
dyBtZW1vcnkgYWRkcmVzcwoKc2V0IGxpbWl0IHRvIGxvdyB3cm9uZ2x5LgoKbWF4X2xvd19wZm5f
bWFwcGVkIGlzIGRpZmZlcmVudCBmcm9tIG1heF9wZm5fbWFwcGVkLgptYXhfbG93X3Bmbl9tYXBw
ZWQgaXMgYWx3YXlzIHVuZGVyIDRHLgoKVGhhdCB3aWxsIG1lbWJsb2NrX2FsbG9jX25pZCBhbGwg
Z28gdW5kZXIgNEcuCgpSZXZlcnQgdGhhdCBvZmZlbmRpbmcgcGF0Y2guCgpSZXBvcnRlZC1ieTog
RGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWWluZ2hh
aSBMdSA8eWluZ2hhaUBrZXJuZWwub3JnPgoKCi0tLQogYXJjaC94ODYvaW5jbHVkZS9hc20vcGFn
ZV90eXBlcy5oIHwgICAgNCArKy0tCiBhcmNoL3g4Ni9rZXJuZWwvc2V0dXAuYyAgICAgICAgICAg
fCAgICAyICstCiAyIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMo
LSkKCkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYvaW5jbHVkZS9hc20vcGFnZV90eXBlcy5oCj09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BhZ2VfdHlw
ZXMuaAorKysgbGludXgtMi42L2FyY2gveDg2L2luY2x1ZGUvYXNtL3BhZ2VfdHlwZXMuaApAQCAt
NTEsOSArNTEsOSBAQCBleHRlcm4gaW50IGRldm1lbV9pc19hbGxvd2VkKHVuc2lnbmVkIGxvCiBl
eHRlcm4gdW5zaWduZWQgbG9uZyBtYXhfbG93X3Bmbl9tYXBwZWQ7CiBleHRlcm4gdW5zaWduZWQg
bG9uZyBtYXhfcGZuX21hcHBlZDsKIAotc3RhdGljIGlubGluZSBwaHlzX2FkZHJfdCBnZXRfbWF4
X2xvd19tYXBwZWQodm9pZCkKK3N0YXRpYyBpbmxpbmUgcGh5c19hZGRyX3QgZ2V0X21heF9tYXBw
ZWQodm9pZCkKIHsKLQlyZXR1cm4gKHBoeXNfYWRkcl90KW1heF9sb3dfcGZuX21hcHBlZCA8PCBQ
QUdFX1NISUZUOworCXJldHVybiAocGh5c19hZGRyX3QpbWF4X3Bmbl9tYXBwZWQgPDwgUEFHRV9T
SElGVDsKIH0KIAogYm9vbCBwZm5fcmFuZ2VfaXNfbWFwcGVkKHVuc2lnbmVkIGxvbmcgc3RhcnRf
cGZuLCB1bnNpZ25lZCBsb25nIGVuZF9wZm4pOwpJbmRleDogbGludXgtMi42L2FyY2gveDg2L2tl
cm5lbC9zZXR1cC5jCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2tlcm5l
bC9zZXR1cC5jCisrKyBsaW51eC0yLjYvYXJjaC94ODYva2VybmVsL3NldHVwLmMKQEAgLTExNzMs
NyArMTE3Myw3IEBAIHZvaWQgX19pbml0IHNldHVwX2FyY2goY2hhciAqKmNtZGxpbmVfcCkKIAog
CXNldHVwX3JlYWxfbW9kZSgpOwogCi0JbWVtYmxvY2tfc2V0X2N1cnJlbnRfbGltaXQoZ2V0X21h
eF9sb3dfbWFwcGVkKCkpOworCW1lbWJsb2NrX3NldF9jdXJyZW50X2xpbWl0KGdldF9tYXhfbWFw
cGVkKCkpOwogCWRtYV9jb250aWd1b3VzX3Jlc2VydmUoMCk7CiAKIAkvKgo=
--f46d0443fddc64c84c04f0b100ee--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
