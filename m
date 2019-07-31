Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE3DCC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:02:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83832206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:02:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="B4AKqiLz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83832206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 165D28E0003; Wed, 31 Jul 2019 08:02:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 116DD8E0001; Wed, 31 Jul 2019 08:02:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1F818E0003; Wed, 31 Jul 2019 08:02:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D18598E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:02:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t124so57956084qkh.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:02:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=tG/l0NrkDg14rMEr9by4Qw9BplAuTm+nc/Gm2QfMFj8=;
        b=mFsJM/wCCAoRWp2oQxCphUrztDy/pwOOcquLeFZd4+bcP9GsVVENvW/+UhLJsz/M/R
         OUc59e1jQCJqTCeDiCaLFI40/lcNyW5b5usN6RbTJvwPlPC0/koKJxA71x3OE/qzNSRz
         BtgBE44d5SHgE6RNVoKJgsYyIxkIlTJ+A3wpGfNGTsfHgNE75VqifReP1WeY/HGJc5V6
         9gYf3aWtNkkTk57OX2zUgYrHgScN12oYY8WChi+4b0SoXQn+5fzwVXji8sZ49GvZuqs4
         pkGTVXyDeYhtgDCVHU9BKUieKjXVez6Jw5ZGi/ZA+yr5qH0L75a6qBMsVkE2AMLMw+Tt
         +tUA==
X-Gm-Message-State: APjAAAXIis/sK1ie47xdt0pT5JxXjxQowvgfRiPL39tv4GEwd/9HzrRh
	8m/cURmaeiD18pOKFpSl3xIARnr266yUaT1Cp3HOYioVh17q6YKmg9na2rkaWg+AEScQA0b5QOS
	inCfZurlqB/IFya1ge5L1FpUGaMj0o+Sj8YB9f/RwqO5D6uAPMoz6Zjonam2To+sFCg==
X-Received: by 2002:ac8:2410:: with SMTP id c16mr84978728qtc.108.1564574553555;
        Wed, 31 Jul 2019 05:02:33 -0700 (PDT)
X-Received: by 2002:ac8:2410:: with SMTP id c16mr84978656qtc.108.1564574552825;
        Wed, 31 Jul 2019 05:02:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564574552; cv=none;
        d=google.com; s=arc-20160816;
        b=h4e2cRSNVxyDqt3UxF0zbqKTCZXBjc9X9X3ASm+4j8vV/BBb0TbLrJK2/f7nRDhmuW
         Rcjtwx99kgSSwk7FuxkiyT5Z3/X2FSmc0/LBUw0yPByLA84RLgE5iG70wmPsouAtwnrB
         wWwWTwvXN0djSEGUHBaF5p4zsnjAEeDl4mskWl4kF8xCCVIZbU4vFaq9z4KzKFO1UELa
         Yt5+yEL9BbYtTgHEm94LAlOkDUpEOziYiRqPmCIwpqmG3k7DI8ExYFuZDfSw4a7ylUO3
         sBDCPQccCAvhMgqFNQO/WVSPKL7w/zKWxHitGB/Ddp6andV4BrV4nFPY6w26FpmNdY9p
         5S4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=tG/l0NrkDg14rMEr9by4Qw9BplAuTm+nc/Gm2QfMFj8=;
        b=GHilmCmIHmd2cPAOp/wV8nPkDkv7HyXaEL4IHz5zPwrQdCQk/jxFgajMU2/QA+N5N/
         7UOwU80iM4efAtd9rFv6PO4lhUEiwHDawBDqSJkMmcR5lhiXIs4xGYNEDEgiTTineaSV
         w+v9IlJN1b65dXE6jEev/L/dIDhYBQmk2NQBlY2dLI8k1pn15z6th88mLVCA0wQN7FtE
         IGExby5BTW9ikjjRQ1BgG5DGq55n8Kt4vnsWiSYWS7tPA4wdLjoz26iDpnFDNFPGX4rr
         8TOxIbPfFFQoHaHwZ/PFxSgeV63b0RH6rlPyulIRvrPXTLGc4flUPB9X7D51OrlP30Jx
         AV6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=B4AKqiLz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor37995956qkj.159.2019.07.31.05.02.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 05:02:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=B4AKqiLz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=tG/l0NrkDg14rMEr9by4Qw9BplAuTm+nc/Gm2QfMFj8=;
        b=B4AKqiLz36y4lPf6dPwpao/1zW+84RvlQXy+xXHQB9BKrHg3XQJgkfWjmfll2oxc7P
         dn+9YiFASeimVqObfthSsrYKhoh0ylS7jT3FDsNLuP/oyK+T/mGyBZE/MLlSY7U0NX3X
         QF/e+Htr0yr9apXv4E+GZOloqsO5G8oLz72DbyY5JNvoUNnmqnhKZjw5k0jDc8yVBzkh
         giixNwYG51471g9FaL3fxTeXQysJZSHOKC9RDzneLPxBCelHsU0rvk0kldJFQU1Y8INJ
         1DRd6yONfnieCma3z3AHbrzoNdoLw7v8g/GBylilfq1IZU3yy+gJ4hUqUlziPzF87Y4F
         sXOQ==
X-Google-Smtp-Source: APXvYqz2CVc9VQF9Pi9Wa96atrpz+M9DwWbg6kXcqZbYIe9r2acl7N0kiOAWVfqxVjosJGmtDDNk5w==
X-Received: by 2002:a05:620a:142e:: with SMTP id k14mr79768693qkj.336.1564574552363;
        Wed, 31 Jul 2019 05:02:32 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id o22sm26810316qkk.50.2019.07.31.05.02.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:02:31 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
From: Qian Cai <cai@lca.pw>
In-Reply-To: <20190731095355.GC63307@arrakis.emea.arm.com>
Date: Wed, 31 Jul 2019 08:02:30 -0400
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Linux-MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>,
 Matthew Wilcox <willy@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <C8EF1660-78FF-49E4-B5D7-6B27400F7306@lca.pw>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
 <1564518157.11067.34.camel@lca.pw>
 <20190731095355.GC63307@arrakis.emea.arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 31, 2019, at 5:53 AM, Catalin Marinas <catalin.marinas@arm.com> =
wrote:
>=20
> On Tue, Jul 30, 2019 at 04:22:37PM -0400, Qian Cai wrote:
>> On Tue, 2019-07-30 at 12:57 -0700, Andrew Morton wrote:
>>> On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas =
<catalin.marinas@arm.com>
>>>> --- a/Documentation/admin-guide/kernel-parameters.txt
>>>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>>>> @@ -2011,6 +2011,12 @@
>>>>  			Built with CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=3Dy,
>>>>  			the default is off.
>>>> =20
>>>> +	kmemleak.mempool=3D
>>>> +			[KNL] Boot-time tuning of the minimum kmemleak
>>>> +			metadata pool size.
>>>> +			Format: <int>
>>>> +			Default: NR_CPUS * 4
>>>> +
>>=20
>> Catalin, BTW, it is right now unable to handle a large size. I tried =
to reserve
>> 64M (kmemleak.mempool=3D67108864),
>>=20
>> [    0.039254][    T0] WARNING: CPU: 0 PID: 0 at mm/page_alloc.c:4707 =
__alloc_pages_nodemask+0x3b8/0x1780
> [...]
>> [    0.039646][    T0] NIP [c000000000395038] =
__alloc_pages_nodemask+0x3b8/0x1780
>> [    0.039693][    T0] LR [c0000000003d9320] =
kmalloc_large_node+0x100/0x1a0
>> [    0.039727][    T0] Call Trace:
>> [    0.039795][    T0] [c00000000170fc80] [c0000000003e5080] =
__kmalloc_node+0x520/0x890
>> [    0.039816][    T0] [c00000000170fd20] [c0000000002e9544] =
mempool_init_node+0xb4/0x1e0
>> [    0.039836][    T0] [c00000000170fd80] [c0000000002e975c] =
mempool_create_node+0xcc/0x150
>> [    0.039857][    T0] [c00000000170fdf0] [c000000000b2a730] =
kmemleak_init+0x16c/0x54c
>> [    0.039878][    T0] [c00000000170fef0] [c000000000ae460c] =
start_kernel+0x69c/0x7cc
>> [    0.039908][    T0] [c00000000170ff90] [c00000000000a7d4] =
start_here_common+0x1c/0x434
> [...]
>> [    0.040100][    T0] kmemleak: Kernel memory leak detector disabled
>=20
> It looks like the mempool cannot be created. 64M objects means a
> kmalloc(512MB) for the pool array in mempool_init_node(), so that hits
> the MAX_ORDER warning in __alloc_pages_nodemask().
>=20
> Maybe the mempool tunable won't help much for your case if you need so
> many objects. It's still worth having a mempool for kmemleak but we
> could look into changing the refill logic while keeping the original
> size constant (say 1024 objects).

Actually, kmemleak.mempool=3D524288 works quite well on systems I have =
here. This
is more of making the code robust by error-handling a large value =
without the
NULL-ptr-deref below. Maybe simply just validate the value by adding =
upper bound
to not trigger that warning with MAX_ORDER.

>=20
>> [   16.192449][    T1] BUG: Unable to handle kernel data access at =
0xffffffffffffb2aa
>=20
> This doesn't seem kmemleak related from the trace.

This only happens when passing a large kmemleak.mempool, e.g., 64M

[   16.193126][    T1] NIP [c000000000b2a2fc] log_early+0x8/0x160
[   16.193153][    T1] LR [c0000000003e6e48] kmem_cache_free+0x428/0x740
[   16.193190][    T1] Call Trace:
[   16.193213][    T1] [c00000002aaefc60] [0000000000000366] 0x366 =
(unreliable)
[   16.193243][    T1] [c00000002aaefd00] [c0000000003c9270]
__mpol_put+0x50/0x70
[   16.193272][    T1] [c00000002aaefd20] [c0000000003c9488]
do_set_mempolicy+0x108/0x170
[   16.193314][    T1] [c00000002aaefdb0] [c000000000010434]
kernel_init+0x64/0x150
[   16.193363][    T1] [c00000002aaefe20] [c00000000000b1cc]
ret_from_kernel_thread+0x5c/0x70

# ./scripts/faddr2line vmlinux log_early+0x8/0x160
log_early+0x8/0x160:
log_early at mm/kmemleak.c:859

