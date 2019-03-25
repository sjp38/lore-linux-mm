Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A203C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:03:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41715206DF
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:03:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41715206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amlogic.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBAD46B0003; Mon, 25 Mar 2019 06:03:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C69F36B0005; Mon, 25 Mar 2019 06:03:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B58FB6B0007; Mon, 25 Mar 2019 06:03:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC716B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 06:03:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d1so2633068pgk.21
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:03:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=H/TXXkpMF4fv6EzUiHz0Hdoa9suBA7BKlJSHnpen/vI=;
        b=AvC5mzR3aAyc23LouYSVEbmKiIhzSxCSRvh3GmpSDQNQBx/J2kgXE0p35rHeX6g9sO
         5Xr2OlwP+tBOUx8YmKB7ISVi4SrfAod5mD64PZWnMHXnYyZQ23XhxgoSwOXz1aTDgYoD
         SCBbvsNP9Y8GC+PjecldxUpKXrL12Cgb9yakMVUK4FV4CM2X/zeBdCZQ0b6WSWaQI6Ef
         qYLyuPROlMq1HI+7g9NQmh+5VH46997ihkXpfyzcOFfS57WJl8yeeq/zUJ0D5z7VHPQY
         yQOYs47LrpretylALNyHwo1mhngUOopYyItoGrLDWCoSeMwuKEentWNy/j4TGWj2vhG2
         Fbww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
X-Gm-Message-State: APjAAAWDcaYgIkHkam5XqN/UFiH+xIWrDwml2/xT1hv7XAdM04P+PO3f
	a3RIDGFGLgtv28C4k4dWSgI4xfelVMyElpeQGt8of/mfUA5hK3XvUAdiqTsB6mDPJLwRwYd/6aX
	zkI2TYbfD22nl5HjhK9y1jJhElHVq3+babPjYTkQt5Z6oaJJddxHM61sVVESFlHW4qQ==
X-Received: by 2002:a17:902:b60c:: with SMTP id b12mr23763168pls.261.1553508183103;
        Mon, 25 Mar 2019 03:03:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcCCzlRcf1oFWzv7AVUY30hAQf/ON7q5Bf6GXCuzvOjDkX7OTnmmOCBBg/KvMvsfaPxbNQ
X-Received: by 2002:a17:902:b60c:: with SMTP id b12mr23763072pls.261.1553508181914;
        Mon, 25 Mar 2019 03:03:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553508181; cv=none;
        d=google.com; s=arc-20160816;
        b=tN1GI4v8DYJ3/JhsQYAGWvdiA8J0I6F8MF6svobirOe12aCfWfgJZmwXNSWi2wTvhd
         HuPxZ1Yf1DDiy6O+5OVLPeJHdTH2degARMpyHgfkV2DmvsO16jtN7yB9JDS7CHT5CNlW
         OUe2QrKCUB0IEmUbh+uD4tVona2g2EdqA0PNxRRMSShI3e8JzQhLEw+91VBIh+vdB0Kt
         iaiFLAqhS7ra1O17WG5cBxLPK+D6jssfh8o533g5AK/5jqfmS6sn7pwKtvLH2F2T+GFW
         7Utv9XdCh3A2oV9DA0vccWJC343NlesT83M8kEX0pSia1X55JCHQuSgN++STCQT4kKhQ
         wAOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=H/TXXkpMF4fv6EzUiHz0Hdoa9suBA7BKlJSHnpen/vI=;
        b=OjbrTXQlPpA16R2c6/ZHCblSr8mNS5bXntuH4Cg8nXka+D19OgW+043x82DS8I2b2j
         z6ddqe7Bv7gZW2wnsRjO5VDwIms+MwjD2g24E/Io+z11WMGlyGJsyrhld3hCUF3atAVK
         mMZzrOKXeHeL3F3sfb4FUZEQUqym4zXijmc4T/Q4729NBPacssGLn76Abi2mhnRQ0a6w
         FnwCoc/g/63trLr3j2yIuy4lQ55TLhkj0n9MZN5X7qOY+zB4w3LuhPaR4xG0CwihyVSN
         vyVFbD1kpKZGNjcBymiJhC0t/edXqKhVsRAYBy4/bDQxbiwt1eiFZFIGx1av8bEVbBJa
         dvpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from mail-sz.amlogic.com (mail-sz.amlogic.com. [211.162.65.117])
        by mx.google.com with ESMTPS id 5si2081326pgg.505.2019.03.25.03.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 03:03:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) client-ip=211.162.65.117;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from [10.28.18.125] (10.28.18.125) by mail-sz.amlogic.com
 (10.28.11.5) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1591.10; Mon, 25 Mar
 2019 18:04:17 +0800
Subject: Re: 32-bit Amlogic (ARM) SoC: kernel BUG in kfree()
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>, Matthew Wilcox
	<willy@infradead.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <akpm@linux-foundation.org>,
	<mhocko@suse.com>, <rppt@linux.ibm.com>, <linux-amlogic@lists.infradead.org>,
	<linux@armlinux.org.uk>, <linux-mtd@lists.infradead.org>
References: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
 <20190321214401.GC19508@bombadil.infradead.org>
 <CAFBinCA6oK5UhDAt9kva5qRisxr2gxMF26AMK8vC4b1DN5RXrw@mail.gmail.com>
From: Liang Yang <liang.yang@amlogic.com>
Message-ID: <5cad2529-8776-687e-58d0-4fb9e2ec59b1@amlogic.com>
Date: Mon, 25 Mar 2019 18:04:17 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CAFBinCA6oK5UhDAt9kva5qRisxr2gxMF26AMK8vC4b1DN5RXrw@mail.gmail.com>
Content-Type: multipart/mixed;
	boundary="------------65F66B8BEFB8B57F8555B6FE"
Content-Language: en-US
X-Originating-IP: [10.28.18.125]
X-ClientProxiedBy: mail-sz.amlogic.com (10.28.11.5) To mail-sz.amlogic.com
 (10.28.11.5)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--------------65F66B8BEFB8B57F8555B6FE
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hi Martin,

On 2019/3/23 5:07, Martin Blumenstingl wrote:
> Hi Matthew,
> 
> On Thu, Mar 21, 2019 at 10:44 PM Matthew Wilcox <willy@infradead.org> wrote:
>>
>> On Thu, Mar 21, 2019 at 09:17:34PM +0100, Martin Blumenstingl wrote:
>>> Hello,
>>>
>>> I am experiencing the following crash:
>>>    ------------[ cut here ]------------
>>>    kernel BUG at mm/slub.c:3950!
>>
>>          if (unlikely(!PageSlab(page))) {
>>                  BUG_ON(!PageCompound(page));
>>
>> You called kfree() on the address of a page which wasn't allocated by slab.
>>
>>> I have traced this crash to the kfree() in meson_nfc_read_buf().
>>> my observation is as follows:
>>> - meson_nfc_read_buf() is called 7 times without any crash, the
>>> kzalloc() call returns 0xe9e6c600 (virtual address) / 0x29e6c600
>>> (physical address)
>>> - the eight time meson_nfc_read_buf() is called kzalloc() call returns
>>> 0xee39a38b (virtual address) / 0x2e39a38b (physical address) and the
>>> final kfree() crashes
>>> - changing the size in the kzalloc() call from PER_INFO_BYTE (= 8) to
>>> PAGE_SIZE works around that crash
>>
>> I suspect you're doing something which corrupts memory.  Overrunning
>> the end of your allocation or something similar.  Have you tried KASAN
>> or even the various slab debugging (eg redzones)?
> KASAN is not available on 32-bit ARM. there was some progress last
> year [0] but it didn't make it into mainline. I tried to make the
> patches apply again and got it to compile (and my kernel is still
> booting) but I have no idea if it's still working. for anyone
> interested, my patches are here: [1] (I consider this a HACK because I
> don't know anything about the code which is being touched in the
> patches, I only made it compile)
> 
> SLAB debugging (redzones) were a great hint, thank you very much for
> that Matthew! I enabled:
>    CONFIG_SLUB_DEBUG=y
>    CONFIG_SLUB_DEBUG_ON=y
> and with that I now get "BUG kmalloc-64 (Not tainted): Redzone
> overwritten" (a larger kernel log extract is attached).
> 
> I'm starting to wonder if the NAND controller (hardware) writes more
> than 8 bytes.
> some context: the "info" buffer allocated in meson_nfc_read_buf is
> then passed to the NAND controller IP (after using dma_map_single).
> 
> Liang, how does the NAND controller know that it only has to send
> PER_INFO_BYTE (= 8) bytes when called from meson_nfc_read_buf? all
> other callers of meson_nfc_dma_buffer_setup (which passes the info
> buffer to the hardware) are using (nand->ecc.steps * PER_INFO_BYTE)
> bytes?
> 
NFC_CMD_N2M and CMDRWGEN are different commands. CMDRWGEN needs to set 
the ecc page size (1KB or 512B) and Pages(2, 4, 8, ...), so 
PER_INFO_BYTE(= 8) bytes for each ecc page.
I have never used NFC_CMD_N2M to transfer data before, because it is 
very low efficient. And I do a experiment with the attachment and find 
on overwritten on my meson axg platform.

Martin, I would appreciate it very much if you would try the attachment 
on your meson m8b platform.

> 
> Regards
> Martin
> 
> 
> [0] https://lore.kernel.org/patchwork/cover/913212/
> [1] https://github.com/xdarklight/linux/tree/arm-kasan-hack-v5.1-rc1
> 

--------------65F66B8BEFB8B57F8555B6FE
Content-Type: text/plain; charset="UTF-8"; name="nand_debug.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nand_debug.diff"

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbXRkL25hbmQvcmF3L21lc29uX25hbmQuYyBiL2RyaXZl
cnMvbXRkL25hbmQvcmF3L21lc29uX25hbmQuYwpvbGQgbW9kZSAxMDA2NDQKbmV3IG1vZGUg
MTAwNzU1CmluZGV4IGU4NThkNTguLjkwNWVmMzkKLS0tIGEvZHJpdmVycy9tdGQvbmFuZC9y
YXcvbWVzb25fbmFuZC5jCisrKyBiL2RyaXZlcnMvbXRkL25hbmQvcmF3L21lc29uX25hbmQu
YwpAQCAtNTI3LDExICs1MjcsMTIgQEAgc3RhdGljIHZvaWQgbWVzb25fbmZjX2RtYV9idWZm
ZXJfcmVsZWFzZShzdHJ1Y3QgbmFuZF9jaGlwICpuYW5kLAogc3RhdGljIGludCBtZXNvbl9u
ZmNfcmVhZF9idWYoc3RydWN0IG5hbmRfY2hpcCAqbmFuZCwgdTggKmJ1ZiwgaW50IGxlbikK
IHsKIAlzdHJ1Y3QgbWVzb25fbmZjICpuZmMgPSBuYW5kX2dldF9jb250cm9sbGVyX2RhdGEo
bmFuZCk7Ci0JaW50IHJldCA9IDA7CisJaW50IHJldCA9IDAsIGk7CiAJdTMyIGNtZDsKIAl1
OCAqaW5mbzsKIAotCWluZm8gPSBremFsbG9jKFBFUl9JTkZPX0JZVEUsIEdGUF9LRVJORUwp
OworCWluZm8gPSBremFsbG9jKDIgKiBQRVJfSU5GT19CWVRFLCBHRlBfS0VSTkVMKTsKKwlt
ZW1zZXQoaW5mbywgMHhGRCwgMiAqIFBFUl9JTkZPX0JZVEUpOwogCXJldCA9IG1lc29uX25m
Y19kbWFfYnVmZmVyX3NldHVwKG5hbmQsIGJ1ZiwgbGVuLCBpbmZvLAogCQkJCQkgUEVSX0lO
Rk9fQllURSwgRE1BX0ZST01fREVWSUNFKTsKIAlpZiAocmV0KQpAQCAtNTQzLDYgKzU0NCwx
MiBAQCBzdGF0aWMgaW50IG1lc29uX25mY19yZWFkX2J1ZihzdHJ1Y3QgbmFuZF9jaGlwICpu
YW5kLCB1OCAqYnVmLCBpbnQgbGVuKQogCW1lc29uX25mY19kcmFpbl9jbWQobmZjKTsKIAlt
ZXNvbl9uZmNfd2FpdF9jbWRfZmluaXNoKG5mYywgMTAwMCk7CiAJbWVzb25fbmZjX2RtYV9i
dWZmZXJfcmVsZWFzZShuYW5kLCBsZW4sIFBFUl9JTkZPX0JZVEUsIERNQV9GUk9NX0RFVklD
RSk7CisKKwlmb3IgKGkgPSAwOyBpIDwgMiAqIFBFUl9JTkZPX0JZVEU7IGkrKyl7CisJCXBy
aW50aygiMHgleCAiLCBpbmZvW2ldKTsNCisJfQorCXByaW50aygiXG4iKTsKKwogCWtmcmVl
KGluZm8pOwogCiAJcmV0dXJuIHJldDsK
--------------65F66B8BEFB8B57F8555B6FE--

