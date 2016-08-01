Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 112DD6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 05:21:35 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so71487765lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 02:21:34 -0700 (PDT)
Received: from jowisz.mejor.pl (jowisz.mejor.pl. [2001:470:1f15:1b61::2])
        by mx.google.com with ESMTPS id a1si30482411wjm.175.2016.08.01.02.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 02:21:33 -0700 (PDT)
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
 <CAM4kBBLsK99PXaCa8Po3huOyGx+qHTrq3Vgsh+FoqqRaMLv-vQ@mail.gmail.com>
From: =?UTF-8?Q?Marcin_Miros=c5=82aw?= <marcin@mejor.pl>
Message-ID: <15aabbf1-4036-cd15-a593-3ebfe429e948@mejor.pl>
Date: Mon, 1 Aug 2016 11:21:11 +0200
MIME-Version: 1.0
In-Reply-To: <CAM4kBBLsK99PXaCa8Po3huOyGx+qHTrq3Vgsh+FoqqRaMLv-vQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitaly.wool@konsulko.com>
Cc: Linux-MM <linux-mm@kvack.org>

W dniu 01.08.2016 o 11:08, Vitaly Wool pisze:
> Hi Marcin,
> 
> Den 1 aug. 2016 11:04 fm skrev "Marcin MirosA?aw" <marcin@mejor.pl
> <mailto:marcin@mejor.pl>>:
>>
>> Hi!
>> I'm testing kernel-git
>> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> <http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git> , at
>> 07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) because I noticed strange OOM
>> behavior in kernel 4.7.0. As for now I can't reproduce problems with
>> OOM, probably it's fixed now.
>> But now I wanted to try z3fold with zswap. When I did `echo z3fold >
>> /sys/module/zswap/parameters/zpool` I got trace from dmesg:
> 
> Could you please give more info on how to reproduce this?

Nothing special. Just rebooted server (vm on kvm), started services and
issued `echo z3fold > ...`

Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
