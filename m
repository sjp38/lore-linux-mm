Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD9FA6B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 11:23:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e1so2428142pfi.10
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 08:23:24 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30094.outbound.protection.outlook.com. [40.107.3.94])
        by mx.google.com with ESMTPS id k10-v6si177267pln.378.2018.02.08.08.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Feb 2018 08:23:24 -0800 (PST)
Subject: Re: INFO: task hung in sync_blockdev
References: <001a11447070ac6fcb0564a08cb1@google.com>
 <20180207155229.GC10945@tassilo.jf.intel.com>
 <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz>
 <CACT4Y+ZTNDhEhAAP2PYRH5WxEeEM0xHdp4UKqtNaWhU6w4sj_g@mail.gmail.com>
 <20180208140833.lpr4yjn7g3v3cdy3@quack2.suse.cz>
 <CACT4Y+bwnyFmgTNMTa1p8WKecH=OU5Za_hboY7Q=V2Aq+DOsKQ@mail.gmail.com>
 <20180208161821.f7x3gopytdtzgf65@quack2.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <22e5e2e1-fd64-1a75-a80c-332a34266717@virtuozzo.com>
Date: Thu, 8 Feb 2018 19:23:44 +0300
MIME-Version: 1.0
In-Reply-To: <20180208161821.f7x3gopytdtzgf65@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andi Kleen <ak@linux.intel.com>, syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org



On 02/08/2018 07:18 PM, Jan Kara wrote:

>> By "full kernel crashdump" you mean kdump thing, or something else?
> 
> Yes, the kdump thing (for KVM guest you can grab the memory dump also from
> the host in a simplier way and it should be usable with the crash utility
> AFAIK).
> 

In QEMU monitor 'dump-guest-memory' command:

(qemu) help dump-guest-memory 
dump-guest-memory [-p] [-d] [-z|-l|-s] filename [begin length] -- dump guest memory into file 'filename'.
                        -p: do paging to get guest's memory mapping.
                        -d: return immediately (do not wait for completion).
                        -z: dump in kdump-compressed format, with zlib compression.
                        -l: dump in kdump-compressed format, with lzo compression.
                        -s: dump in kdump-compressed format, with snappy compression.
                        begin: the starting physical address.
                        length: the memory size, in bytes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
