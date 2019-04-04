Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08B71C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:44:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF5382184B
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:44:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LQWIGFVO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF5382184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 588F46B0269; Thu,  4 Apr 2019 12:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5380C6B026A; Thu,  4 Apr 2019 12:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 427846B026B; Thu,  4 Apr 2019 12:44:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 086206B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:44:49 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d1so1887351pgk.21
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:44:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=Xy+ReW4WdLg6r3y8MidIxbAapRZPzkiZdvdN2N1NwHE=;
        b=rs8LsrMzO/8zimfoOWw/+qtpjbjM/CTlvoHGLMwhqesTuZGFM87pnK0Ego6Uq2LaU2
         ZSVefFBQ7hnkiOC0Tv2waeI7d+q4wHOsP+1yBnkEjpyGPzuxpxFBKNh4WXVD/EW8NpaN
         bU4gSjHtm8Na6S2cs5ctk725bT+m0si3XOM4du0U4eErPZ6zCneJRl5Imz0tpF/55imY
         2QEYeKTiST0wE59dOA+j1JBQDFB5BMkA8xIuYUKX4VDIb0xCBKU5hIXKke5yWd5mvStC
         w3YQgqtuL0sjCndeLWBgOThP3WuU+jl2wOHacVKvNl8hn2+Jg+RhfJIbm6iwKqNa2Llg
         rXyw==
X-Gm-Message-State: APjAAAU8YxVgBvKeSr+Ny1TZp+40DiT5kz6gmoQK6hI811YYZUl/njrr
	fLF/QK+Am3I4S8JibFGSqmDxJun0KA3IlvGQmXHzGEEusxv9hGSchLp4lHcbPpG1b9r+6YHNFRI
	ctn8USUsUBHbuBHPny7yF3V+rEAXucBfk3Y+hXKR4aODiakGd4CQ8snKMxH5ZbX14dw==
X-Received: by 2002:a62:874d:: with SMTP id i74mr7021463pfe.211.1554396288391;
        Thu, 04 Apr 2019 09:44:48 -0700 (PDT)
X-Received: by 2002:a62:874d:: with SMTP id i74mr7021379pfe.211.1554396287342;
        Thu, 04 Apr 2019 09:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554396287; cv=none;
        d=google.com; s=arc-20160816;
        b=EJWNn9lHI6mMzKshAMYLMyIm4x71is/ZPYfstO/79W9p/0hqNMgvXlUkVkkbrYpxFg
         mOvzvuJ+voQOsQt7k9kC+TYe4BAXpwt4vYM9KGqQik/DZPeUHekdx4oCJ4NRyTIMg5Fp
         zvQQ9q7aGoGVLd7KS+mDev/g9nduE/bWsttBrnGlVREm0bOisNI/MFxTwc4a7sbW9vuX
         dSpqXqYqrDP8MbKkzvaCQKsSVwzVQvLlHKVkHCK+oBC1lMQQV5kT16Yl6/8fVn1hWCKR
         dvAgAq62TO1N0/AP6pCgjFZN7Axs5cg8hG0/vjHP+tL6j4Q0PY+x1x2cp+2mAtbwDtp6
         HCow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=Xy+ReW4WdLg6r3y8MidIxbAapRZPzkiZdvdN2N1NwHE=;
        b=bsshhVYx9kpix6/aE2V+KeTwQ3iDIszTCU6UkRgjXl+wAP/Nes3kUvEDP4U7kADcon
         EYfXG4DIfsJYEJu6ittwSMDJ5InwbCPc6Ishtm7wqisRQYm/NqTmivaUpIDihNkArMZ4
         u8c3B3SunOxmuTwYnjp87seT8/oz44ObQMdarFkpEYoj9v4lck7BUw9IceYiWqyd6Rbx
         uvzOmir8mt5Von/mdQRNGO1LgZqohb+xAj42JaBeP1IFrk65b8/IdaLvzO64+Zgw+uha
         W/9Joq/E0XW4W0U6ayqepWvUbX/BqyrOzrL/huhubcYBbYUTMXcVF6DTzczemO/M7axb
         bcsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LQWIGFVO;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id go19sor25298215plb.66.2019.04.04.09.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 09:44:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LQWIGFVO;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Xy+ReW4WdLg6r3y8MidIxbAapRZPzkiZdvdN2N1NwHE=;
        b=LQWIGFVO8E5mI4/pB2iT2o/XMJow15/aaRgvT4gmragYFUbh2dZaZYUQPRUxsYL4VG
         bg8qxJ9bLM2138IvXNwujUVHpFQP1nuoB8dSQU2YvPH+KANZdslxHlIY7PEFuwn1NWKC
         UwP4wcQZoT0vsldKl4EJh1scM/nLuVssLzHnnD3nuhdra9KXmWvmh88Fhh8C9U4OFasS
         9Fwq1ip+ACOW93YiPXQsR/oziYYiYHpuAKWTWmmFmmrrEGu+2Tb2vwSZPfmNI/eWzA5D
         gT2g4xqETl99tSK9TMrd/ixA7fuo82WwgemMLh7qmDJfbPJTpcQdW+wELfxwHFulGEsG
         InqA==
X-Google-Smtp-Source: APXvYqy1o4DnqvcD19gMmNPsciMs9n+AzUt25Yw2ibm5ieYpF8E7FJWJfMRKaeTNL61yJu541XFuTg==
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr7526914plb.147.1554396286248;
        Thu, 04 Apr 2019 09:44:46 -0700 (PDT)
Received: from [10.33.115.113] ([66.170.99.2])
        by smtp.gmail.com with ESMTPSA id m3sm21957806pgp.85.2019.04.04.09.44.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:44:45 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH v9 00/13] Add support for eXclusive Page Frame
 Ownership
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
Date: Thu, 4 Apr 2019 09:44:43 -0700
Cc: X86 ML <x86@kernel.org>,
 linux-arm-kernel@lists.infradead.org,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>,
 LSM List <linux-security-module@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3F95B70B-7910-4150-A9D3-05C4D0195B67@gmail.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Apr 3, 2019, at 10:34 AM, Khalid Aziz <khalid.aziz@oracle.com> =
wrote:
>=20
> This is another update to the work Juerg, Tycho and Julian have
> done on XPFO.

Interesting work, but note that it triggers a warning on my system due =
to
possible deadlock. It seems that the patch-set disables IRQs in
xpfo_kunmap() and then might flush remote TLBs when a large page is =
split.
This is wrong, since it might lead to deadlocks.


[  947.262208] WARNING: CPU: 6 PID: 9892 at kernel/smp.c:416 =
smp_call_function_many+0x92/0x250
[  947.263767] Modules linked in: sb_edac vmw_balloon crct10dif_pclmul =
crc32_pclmul joydev ghash_clmulni_intel input_leds intel_rapl_perf =
serio_raw mac_hid sch_fq_codel ib_iser rdma_cm iw_cm ib_cm ib_core =
vmw_vsock_vmci_transport vsock vmw_vmci iscsi_tcp libiscsi_tcp libiscsi =
scsi_transport_iscsi ip_tables x_tables autofs4 btrfs zstd_compress =
raid10 raid456 async_raid6_recov async_memcpy async_pq async_xor =
async_tx libcrc32c xor raid6_pq raid1 raid0 multipath linear hid_generic =
usbhid hid vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt =
fb_sys_fops ttm drm aesni_intel psmouse aes_x86_64 crypto_simd cryptd =
glue_helper mptspi vmxnet3 scsi_transport_spi mptscsih ahci mptbase =
libahci i2c_piix4 pata_acpi
[  947.274649] CPU: 6 PID: 9892 Comm: cc1 Not tainted 5.0.0+ #7
[  947.275804] Hardware name: VMware, Inc. VMware Virtual Platform/440BX =
Desktop Reference Platform, BIOS 6.00 07/28/2017
[  947.277704] RIP: 0010:smp_call_function_many+0x92/0x250
[  947.278640] Code: 3b 05 66 fc 4e 01 72 26 48 83 c4 10 5b 41 5c 41 5d =
41 5e 41 5f 5d c3 8b 05 2b cc 7e 01 85 c0 75 bf 80 3d a8 99 4e 01 00 75 =
b6 <0f> 0b eb b2 44 89 c7 48 c7 c2 a0 9a 61 aa 4c 89 fe 44 89 45 d0 e8
[  947.281895] RSP: 0000:ffffafe04538f970 EFLAGS: 00010046
[  947.282821] RAX: 0000000000000000 RBX: 0000000000000006 RCX: =
0000000000000001
[  947.284084] RDX: 0000000000000000 RSI: ffffffffa9078d70 RDI: =
ffffffffaa619aa0
[  947.285343] RBP: ffffafe04538f9a8 R08: ffff9d7040000ff0 R09: =
0000000000000000
[  947.286596] R10: 0000000000000000 R11: 0000000000000000 R12: =
ffffffffa9078d70
[  947.287855] R13: 0000000000000000 R14: 0000000000000001 R15: =
ffffffffaa619aa0
[  947.289118] FS:  00007f668b122ac0(0000) GS:ffff9d727fd80000(0000) =
knlGS:0000000000000000
[  947.290550] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  947.291569] CR2: 00007f6688389004 CR3: 0000000224496006 CR4: =
00000000003606e0
[  947.292861] DR0: 0000000000000000 DR1: 0000000000000000 DR2: =
0000000000000000
[  947.294125] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: =
0000000000000400
[  947.295394] Call Trace:
[  947.295854]  ? load_new_mm_cr3+0xe0/0xe0
[  947.296568]  on_each_cpu+0x2d/0x60
[  947.297191]  flush_tlb_all+0x1c/0x20
[  947.297846]  __split_large_page+0x5d9/0x640
[  947.298604]  set_kpte+0xfe/0x260
[  947.299824]  get_page_from_freelist+0x1633/0x1680
[  947.301260]  ? lookup_address+0x2d/0x30
[  947.302550]  ? set_kpte+0x1e1/0x260
[  947.303760]  __alloc_pages_nodemask+0x13f/0x2e0
[  947.305137]  alloc_pages_vma+0x7a/0x1c0
[  947.306378]  wp_page_copy+0x201/0xa30
[  947.307582]  ? generic_file_read_iter+0x96a/0xcf0
[  947.308946]  do_wp_page+0x1cc/0x420
[  947.310086]  __handle_mm_fault+0xc0d/0x1600
[  947.311331]  handle_mm_fault+0xe1/0x210
[  947.312502]  __do_page_fault+0x23a/0x4c0
[  947.313672]  ? _cond_resched+0x19/0x30
[  947.314795]  do_page_fault+0x2e/0xe0
[  947.315878]  ? page_fault+0x8/0x30
[  947.316916]  page_fault+0x1e/0x30
[  947.317930] RIP: 0033:0x76581e
[  947.318893] Code: eb 05 89 d8 48 8d 04 80 48 8d 34 c5 08 00 00 00 48 =
85 ff 74 04 44 8b 67 04 e8 de 80 08 00 81 e3 ff ff ff 7f 48 89 45 00 8b =
10 <44> 89 60 04 81 e2 00 00 00 80 09 da 89 10 c1 ea 18 83 e2 7f 88 50
[  947.323337] RSP: 002b:00007ffde06c0e40 EFLAGS: 00010202
[  947.324663] RAX: 00007f6688389000 RBX: 0000000000000004 RCX: =
0000000000000001
[  947.326317] RDX: 0000000000000000 RSI: 0000000001000001 RDI: =
0000000000000017
[  947.327973] RBP: 00007f66883882d8 R08: 00000000032e05f0 R09: =
00007f668b30e6f0
[  947.329619] R10: 0000000000000002 R11: 00000000032e05f0 R12: =
0000000000000000
[  947.331260] R13: 00007f6688388230 R14: 00007f6688388288 R15: =
00007f668ac3b0a8
[  947.332911] ---[ end trace 7d605a38c67d83ae ]---=

