Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D52FCC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:13:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C14420848
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:13:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="TFq7ktoK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C14420848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E472B8E0003; Tue,  5 Mar 2019 10:13:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF7018E0001; Tue,  5 Mar 2019 10:13:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE4D48E0003; Tue,  5 Mar 2019 10:13:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A62688E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 10:13:27 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y6so7258749qke.1
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 07:13:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=X77yG42pUTh+5q7ynq04fFgp9WPenAz/q5e6Uo+Z9Tw=;
        b=P8qiI/qIPUHT4MTucJCzjv2Xjeq5OQCAqsvMYt3RXO7YhfR0ce5nvNsCCOk+Y7AKXg
         v5umgiM/YMPCexw8xfuii1CSaCqUt9UhFXGH8wCS0y86lag1AxETu6xIeWiXeBiz8p59
         KmS5opoYg3NxH2E1hgcH9bdIp8I98b6T67IEi5CqTozKv79T3obbCpWGuRDrgh0KO6et
         fF/MQtiejZksD3nv7V+SdmIMehPg3AA9xPK4EsOvHI+p9HZMUmLygXg5rWcorEg1iOq/
         Cd+Ly9QSDafWjHTPDHqvIvtVBzu5Gv40Qyu7hBq6JiRuvhvu5/nKqIPPSD3WqfL+qX00
         7m8g==
X-Gm-Message-State: APjAAAX6vBfHNY0SU1pX7UG6wf8EagcFGPxdE9PkFme7b0dCDd/G75O0
	0TKiaWmPFyzB+CpzIDRZgqoeL0Z9n/mZcRZvyLw2caGt//TO51AObzO4zflFBRO1IGgDEI7WjO5
	JmeDlL70OQuMitXVVUnm5p0aa0Qt+OWNgaweDKpTh7cEwW7mBY9GU0pMW75XzC+DU3B+3emWfIQ
	YmZxLrTP1y74Zk3d3fNKbtSM1kD8eLzhzKI+Z+8sq9vi6ddScwjJ5wAWfx1TSUdpIvl2fvbe/6/
	Hsx+mE/R3eEcq1S/NajWFeTbrfRPUh/Qk6gLGjoJsZqafTyPVTbO63Yx/WgPY+nROLhGFlGNb1r
	eqZ+XKGo36wgnwddoH81ZdJopULrJGTqipNkIhm1riCKymhzwgM1gSUPAo+9TyTe/GLNb7XLB3I
	/
X-Received: by 2002:ac8:18fa:: with SMTP id o55mr1816339qtk.272.1551798807373;
        Tue, 05 Mar 2019 07:13:27 -0800 (PST)
X-Received: by 2002:ac8:18fa:: with SMTP id o55mr1816257qtk.272.1551798806261;
        Tue, 05 Mar 2019 07:13:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551798806; cv=none;
        d=google.com; s=arc-20160816;
        b=dkVefFZnfKiUDww0ymdIN9AKLFHCpU/PUfeOwHEcLeRYQTkZgKZuhAZzU8XkCyUFaH
         Xs8o/BS4H9rrPMqpe9zVwRMHUfKBsiuvS7pP11WOUYBPBJlRmY56Qu3VymfUyj4NgZ5r
         xq+51hFmZPfSAHWuQ7xeboL5Y48wBgITkOJ7cA5aFPziClCHQQo5zqrQc7gmes4MTE7W
         MNM5G55mIs5ln1AiQJnbQElN7X1wCuhx/cARPsYFNSWqI/sESTPUcOdJ9mXR7m1zub6S
         P3Zr6sFLqKVdB+E7ZhvcuM9YdpnE0Fi1r/4RCUWpXXIIV/xGr2h/YowxwxVFjmkXLzqs
         EDHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=X77yG42pUTh+5q7ynq04fFgp9WPenAz/q5e6Uo+Z9Tw=;
        b=sPXz08zEa90S5MF03NQhyQKCD5XXSc41KDbixBWa+DuKcA7H6wavwxyFS36aEDCGqg
         4XSEa5h9qxclcr+MzFFE4AJLWwkFGYdhTSslFEZ17l7RfbgPyM99WqSIJoiXgpMyEwB3
         83KCcPrzyOXgYh3FTIt7Hcvxbwi/l77cumjGVC0YurjrmL7I4Hlp9/dZ0Wdx2kUclVCD
         6Re0/616DCLxC/7UROTuAxX70gBTgsIvBfFYTIjvKlHM12J0ITZDYYG6t5vLbBil7ZR1
         j/DCuVPGedGrfT0PUisX2uWcBxio7Noj3W8YxD8uJFbTlNmjnpWuukgJlnpNN6hOwC6q
         L08A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TFq7ktoK;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x28sor11052530qtc.32.2019.03.05.07.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 07:13:26 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TFq7ktoK;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=X77yG42pUTh+5q7ynq04fFgp9WPenAz/q5e6Uo+Z9Tw=;
        b=TFq7ktoKOxdpEqYEL4l07jqYMHhtC9a+FjXfjmf3PWERiSr/Ci1mpdmLhCrz/QSB+x
         yGpo2O4nwfipKDlSoghcbnD1L1836rj2m5qnGP6i7XrR39HS6nP5G1Uu2z3ZIOag6c+h
         zDPn4/PBRyAtthgVJfDLPJ9DjIhxwYeFjQzIlEb2dplXS4PzwxmE77OPu3gVoNZwpdjA
         VkgxjtABP98gn6Dk1zkhP5ao/NBTIg8RnF783JWQEgvQfB9zy/49ccP0Nu4HIgswnGJ/
         eMZWu60GPwieSwWPN8oJ2S3vABlLw1xF7WvxaOgJ4NSLjjPoMZ5Bl8poK5+Vnj9yeh+u
         Nq+g==
X-Google-Smtp-Source: APXvYqwSM6J3Pemd22wl1bS40l1eEpvw3I3pMZa8xroNk8cYj6q2d3HtACw5hTQa25tQlAW1jmJ+cg==
X-Received: by 2002:aed:3536:: with SMTP id a51mr1791065qte.308.1551798805802;
        Tue, 05 Mar 2019 07:13:25 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id h58sm6562457qtb.89.2019.03.05.07.13.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 07:13:25 -0800 (PST)
Message-ID: <1551798804.7087.7.camel@lca.pw>
Subject: Re: low-memory crash with patch "capture a page under direct
 compaction"
From: Qian Cai <cai@lca.pw>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
Date: Tue, 05 Mar 2019 10:13:24 -0500
In-Reply-To: <20190305144234.GH9565@techsingularity.net>
References: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
	 <20190305144234.GH9565@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-05 at 14:42 +0000, Mel Gorman wrote:
> On Mon, Mar 04, 2019 at 10:55:04PM -0500, Qian Cai wrote:
> > Reverted the patches below from linux-next seems fixed a crash while running
> > LTP
> > oom01.
> > 
> > 915c005358c1 mm, compaction: Capture a page under direct compaction -fix
> > e492a5711b67 mm, compaction: capture a page under direct compaction
> > 
> > Especially, just removed this chunk along seems fixed the problem.
> > 
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -2227,10 +2227,10 @@ compact_zone(struct compact_control *cc, struct
> > capture_control *capc)
> >                 }
> > 
> >                 /* Stop if a page has been captured */
> > -               if (capc && capc->page) {
> > -                       ret = COMPACT_SUCCESS;
> > -                       break;
> > -               }
> > 
> 
> It's hard to make sense of how this is connected to the bug. The
> out-of-bounds warning would have required page flags to be corrupted
> quite badly or maybe the use of an uninitialised page. How reproducible
> has this been for you? I just ran the test 100 times with UBSAN and page
> alloc debugging enabled and it completed correctly.
> 

I did manage to reproduce this every time by running oom01 within 3 tries on
this x86_64 server and was unable to reproduce on arm64 and ppc64le servers so
far.

# for i in `seq 1 3`; do /opt/ltp/testcases/bin/oom01 ; done

Sometimes, it could trigger different traces.

[  391.704320] SLUB: Unable to allocate memory on node -1,
gfp=0x800(GFP_NOWAIT)
[  391.737794]   cache: kmalloc-64, object size: 64, buffer size: 416,
default order: 2, min order: 0
[  391.778079]   node 0: slabs: 5999, objs: 232851, free: 16
[  391.802926]   node 1: slabs: 4303, objs: 167067, free: 37
[  499.866479] ------------[ cut here ]------------
[  499.866500] BUG: Bad page state in process oom01  pfn:fffffe7a09fffd07
[  499.890013] kernel BUG at mm/page_alloc.c:3124!
[  499.935430] double fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[  499.971334] CPU: 0 PID: 1623 Comm: oom01 Tainted: G        W
5.0.0-next-20190305+ #49
[  499.992805]
================================================================================
[  500.009887] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9,
BIOS U20 10/25/2017
[  500.009901] RIP: 0010:check_memory_region+0x10/0x1e0
[  500.048252] UBSAN: Undefined behaviour in
kernel/locking/qspinlock.c:138:9
[  500.085378] Code: 00 00 00 48 89 e5 e8 ff 3e 9f 00 5d c3 0f 1f 00 66 2e
0f 1f 84 00 00 00 00 00 48 85 f6 0f 84 68 01 00 00 55 0f b6 d2 48 89 e5
<41> 55 41 54 53 e9 b3 00 00 00 48 b8 00 00 00 00 00 00 00 ff 48 39
[  500.107608] index 8190 is out of range for type 'long unsigned int
[256]'
[  500.138462] RSP: 0000:ffff888428f80000 EFLAGS: 00010002
[  500.223186] CPU: 42 PID: 0 Comm: swapper/42 Tainted: G        W
5.0.0-next-20190305+ #49
[  500.253922] RAX: ffff88827fff41c0 RBX: ffff88827fff41c8 RCX:
ffffffff9c0a9468
[  500.253925] RDX: 0000000000000000 RSI: 0000000000000004 RDI:
ffff88827fff41f8
[  500.277367] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9,
BIOS U20 10/25/2017
[  500.277370] Call Trace:
[  500.318081] RBP: ffff888428f80000 R08: ffffed104fffe840 R09:
ffffed104fffe83f
[  500.318085] R10: ffffed104fffe83f R11: ffff88827fff41fb R12:
ffff88827fff41f8
[  500.349838]  <IRQ>
[  500.381765] R13: ffff88827fff41c8 R14: ffff88842a96f770 R15:
ffff88827fff41c8
[  500.381768] FS:  00007fdfd3559700(0000) GS:ffff8881f3c00000(0000)
knlGS:0000000000000000
[  500.424074]  dump_stack+0x62/0x9a
[  500.435452] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  500.435455] CR2: ffff888428f7fff8 CR3: 000000041abca003 CR4:
00000000001606b0
[  500.467546]  ubsan_epilogue+0xd/0x7f
[  500.500039] Call Trace:
[  500.500042] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat
kvm_intel kvm irqbypass efivars ip_tables x_tables xfs sd_mod ahci igb
libahci i2c_algo_bit i2c_core libata dm_mirror dm_region_hash dm_log dm_mod
efivarfs
[  500.509058]  __ubsan_handle_out_of_bounds+0x14d/0x192
[  500.541152] ---[ end trace f9ff2b89b6b88c5f ]---
[  500.541155] invalid opcode: 0000 [#2] SMP DEBUG_PAGEALLOC KASAN PTI
[  500.541159] CPU: 10 PID: 262 Comm: kcompactd0 Tainted: G      D W
5.0.0-next-20190305+ #49
[  500.541161] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9,
BIOS U20 10/25/2017
[  500.541167] RIP: 0010:__isolate_free_page+0x464/0x600
[  500.541170] Code: 31 c0 5b 41 5c 41 5d 41 5e 41 5f 5d c3 48 c7 c6 20 6f
0b 9d 48 89 df e8 4a 8b f8 ff 0f 0b 48 c7 c7 a0 32 69 9d e8 51 40 43 00
<0f> 0b 48 c7 c7 e0 31 69 9d e8 43 40 43 00 48 c7 c6 80 71 0b 9d 48
[  500.541172] RSP: 0000:ffff8881f1fdf848 EFLAGS: 00010002
[  500.541175] RAX: 00000000f0000080 RBX: ffffea00064fc000 RCX:
ffff88827fff41d0
[  500.541177] RDX: 1ffffd4000c9f806 RSI: 0000000000000008 RDI:
ffffffff9d9f1640
[  500.541179] RBP: ffff8881f1fdf898 R08: ffffea00064fc000 R09:
ffff8881f1fdfd30
[  500.541181] R10: 0000000000000002 R11: 1ffff1104fffe83b R12:
0000000000000008
[  500.541183] R13: dffffc0000000000 R14: ffff88827fff3000 R15:
0000000000000002
[  500.541185] FS:  0000000000000000(0000) GS:ffff8881f4100000(0000)
knlGS:0000000000000000
[  500.541188] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  500.541190] CR2: 00007fdce416a000 CR3: 000000026ea16002 CR4:
00000000001606a0
[  500.541191] Call Trace:
[  500.541199]  compaction_alloc+0x886/0x25f0
[  500.541221]  unmap_and_move+0x37/0x1e70
[  500.541228]  migrate_pages+0x2ca/0xb20
[  500.541238]  compact_zone+0x19cb/0x3620
[  500.541252]  kcompactd_do_work+0x2df/0x680

