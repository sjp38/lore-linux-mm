Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66C89C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 09:59:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1255520657
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 09:59:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Tc7GJQHi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1255520657
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4B148E0003; Thu, 17 Jan 2019 04:59:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFAD78E0002; Thu, 17 Jan 2019 04:59:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F6E88E0003; Thu, 17 Jan 2019 04:59:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74DB98E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:59:00 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id j3so201876itf.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:59:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=t6bIZ+7wvX1DvoXEYmYPW0X0bnw7md2Ir4xWInKIrr0=;
        b=Lw2cXNjfBUEDRzWz3PGo87XP+eDkRS8UEX3KiKeBN1kdln6XCJkj6ksT0Cc/+GJxsT
         N46xpIH0yqdXmx1BaVEWr+4DjOW8QZwy3gUGqTJrlTFCFS8Xfpvju/FwnzzimzvrYQPy
         VVBbksguOj3dTnxUeR5sQzUQC1lmGSXzbXiK2rZCWc925Xu+ZVxioi9t4LBr9hZqROfe
         HhPluFDKPO34k7wUL51w7hZaevWYQ4jIT48LG9qCgr3QjW+NCR6YghLZ7QsbGDOKBGA2
         DCdLVSSMgrSNdZsS0dZpnA43ihGYV0i8bWjSMQ0wp4hFUBP/Q1WG4VMj81xE5ake5cfQ
         hWSw==
X-Gm-Message-State: AJcUukcxpwfBqBphi1aAGTBiNbXDmYY5wZd731X6dM7B7Hgg1IwVZ455
	4+g5tofEZiMFfc0ddILglxHmpjtFhjUzSxwxPjQJVYwrZbvWhKygVQi/PjALVZCvkJ5YjsgZyqw
	Bhf2exvMNMuKYp/8M3/ZHQ/wDppiFPHOJvy8NIzEh8Kj64pk7sGuCOUPeymrWHvedNYRAIeDzax
	9GqVGchJOCKgU7FLzQf6YM//zC6AbbLIgS4R3xZAOSKFeqTSK7w08EakPzsyEG0gHZ6egBhT8wx
	AkSgz6sMJuOxrz1K/paZS8d28nBUOsbhDmWhS3uQCCucDgrHxwnaMVxAbQriRlDPWjgD9XvFf0x
	OyfGEjVhJpNKhASnlTtK8Q1mdCx9u4lvKiPKW1i0k1CXjfU2U89BRQNdF8VDt5/E/0MgmbYPrDJ
	t
X-Received: by 2002:a02:330d:: with SMTP id c13mr7827239jae.95.1547719140186;
        Thu, 17 Jan 2019 01:59:00 -0800 (PST)
X-Received: by 2002:a02:330d:: with SMTP id c13mr7827219jae.95.1547719139333;
        Thu, 17 Jan 2019 01:58:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547719139; cv=none;
        d=google.com; s=arc-20160816;
        b=GGAfCuVPMdbVOrk1Jlzz3js9m+FW82IqIgaEkBhdOrVjd+6Ku3K+iI6clYCGwJWgsg
         8gUcTT/JTGwXgh6V6SCzC9net6zdGNqp9+gv9l62fLHUuTLxOS0G+2gWKuEPNdlCMZlD
         7xyTQPvO7HcHbyMP7s9sL8YZjDSJBYdpLRvGwWxubX2Xjqv3aqnx8sY7rtztmK2s9lC6
         dftaA7MXrbragdb/poGHVjc97E89VkbZhuAqMGJCvie+M2Ms9T9KJUqeaJTidix9UFrY
         HiO+IiY/snOFnwvMhRNT6VtZTw5O/WXpnJI7aeWFL/YBbTonisLtGWW8fCQfymxYQrVs
         iayQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=t6bIZ+7wvX1DvoXEYmYPW0X0bnw7md2Ir4xWInKIrr0=;
        b=Hsd5v6+SFzfaaEal/7QrFyLTHUWy++2MAkF1ue+OUqP8APLLVvaw5dWoM1y9+OcdZH
         si/w3qfsED/WbWHsPIF4Rkcqf+Z71M9biQay2ZIzkTM8wexfxH9FQXI0j0b/eH7ZZ2wt
         pZzzVu/jdE2QLTrLrlbzrh7LQOpIvr1VTKo0oCSpzsNf7d1HyBpmMVkAndGbQgeqpM5q
         gkkflgpqloBXcLz3lMrqLBarhI8pCYLj7/xzJljuF+a07LGPyCOCVkneipnaMal0M9J6
         mbN3joaZbRF6N8cWq6HYch3Ve54JpIVPd2pPl7vXyTvT7ovBwMdog8J39M1GO+N/GJgP
         YPfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Tc7GJQHi;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r203sor1623763ita.23.2019.01.17.01.58.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 01:58:59 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Tc7GJQHi;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=t6bIZ+7wvX1DvoXEYmYPW0X0bnw7md2Ir4xWInKIrr0=;
        b=Tc7GJQHib2hS8ExAYG7FL4jtRgaOSy5t0Cq95AKSSVtqW03yRHjH26k8XzkIrZh0Wd
         FK2QzgvnxmUDdptYea1AxlgAWbbAiOiP/We9IlomjrXDEuYsYu1KluJx/74ALqZFlJDs
         ORHASw9p9jmHR6ysDUZIhk0cG3S8oQaWdeHtdv+ZmERyCSWfL6+NkQ6lXuJevGLdEGYu
         CO+Vl9kikGkwjyk0/W+3rA0YSz8naViMtHrwvgur/tJu5CHj00KgfQbiPYkfeoG6W6H9
         cgqQCDKgRakMG0lnMWqyIkyVXFJNAqCb8xJU27LZCoXgUfpnJq0303hBmr3BXHvkCsio
         Jc3g==
X-Google-Smtp-Source: ALg8bN7rBxarKl0xeN6ZlGavjO8CRSHeSJfGwUU4R7qYg/QG2cp9M3ZwgxnTWX/zfMa3CYIAnckAqgq1TI5C1Mzz9GE=
X-Received: by 2002:a24:f14d:: with SMTP id q13mr1456674iti.166.1547719138716;
 Thu, 17 Jan 2019 01:58:58 -0800 (PST)
MIME-Version: 1.0
References: <000000000000cdc61b057f9e360e@google.com> <e4cb6380-b462-857e-3219-319fdbfa6f81@suse.cz>
In-Reply-To: <e4cb6380-b462-857e-3219-319fdbfa6f81@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 17 Jan 2019 10:58:47 +0100
Message-ID:
 <CACT4Y+ZG1LLb_7ZyhijWJxLbrbBuP_h2++RWUfnZ65Dj9=MNkw@mail.gmail.com>
Subject: Re: kernel BUG at mm/page_alloc.c:LINE!
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117095847.cfMnIJcn9-NZSiAzvwo8XzcGIPVoeflPQxkUVnY5eK4@z>

On Thu, Jan 17, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/17/19 3:33 AM, syzbot wrote:
> > Hello> syzbot found the following crash on:
> >
> > HEAD commit:    b808822a75a3 Add linux-next specific files for 20190111
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=16a471d8c00000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=c052ead0aed5001b
> > dashboard link: https://syzkaller.appspot.com/bug?extid=80dd4798c16c634daf15
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com
> >
> > ------------[ cut here ]------------
> > kernel BUG at mm/page_alloc.c:3112!
>
> Why does the mail subject say LINE, anyway?

The title is what syzbot uses as bug identity and for deduplication purposes.
We have to remove some moving parts, like lines/addresses/etc, so that
it does not create a new bug whenever the line changes:
https://github.com/google/syzkaller/blob/43689bcfed82ecb780bd0e54543609fe3c080623/pkg/report/report.go#L166-L168


> > invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> > CPU: 0 PID: 1043 Comm: kcompactd0 Not tainted 5.0.0-rc1-next-20190111 #10
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: 0010:__isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3112
>
> That's BUG_ON(!PageBuddy(page)); in __isolate_free_page().
>
> > Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd
> > ff ff 48 c7 c6 a0 63 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6
> > c0 64 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
> > RSP: 0000:ffff8880a78e6f58 EFLAGS: 00010007
> > RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88812fffc7e0
> > RDX: 1ffff11025fff8fc RSI: 0000000000000007 RDI: ffff88812fffc7b0
> > RBP: ffff8880a78e7018 R08: ffff8880a78ce000 R09: ffffed1014f1cdf2
> > R10: ffffed1014f1cdf1 R11: 0000000000000003 R12: ffff88812fffc7b0
> > R13: 1ffff11014f1cdf2 R14: ffff88812fffc7b0 R15: ffff8880a78e6ff0
> > FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000438ca0 CR3: 0000000009871000 CR4: 00000000001426f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> > Call Trace:
> >   fast_isolate_freepages mm/compaction.c:1356 [inline]
>
> Mel's new code... but might be just a victim of e.g. bad struct page
> initialization?
>
> >   isolate_freepages mm/compaction.c:1429 [inline]
> >   compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
> >   unmap_and_move mm/migrate.c:1177 [inline]
> >   migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
> >   compact_zone+0x2207/0x3e90 mm/compaction.c:2173
> >   kcompactd_do_work+0x6de/0x1200 mm/compaction.c:2564
> >   kcompactd+0x251/0x970 mm/compaction.c:2657
> >   kthread+0x357/0x430 kernel/kthread.c:247
> >   ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> > Modules linked in:
> >
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 5.0.0-rc1-next-20190111 #10 Not tainted
> > ------------------------------------------------------
>
> Dunno about that, but doesn't seem to be the root cause anyway.
>
> > -> #0 (console_owner){-.-.}:
> >         lock_acquire+0x1db/0x570 kernel/locking/lockdep.c:3860
> >         console_lock_spinning_enable kernel/printk/printk.c:1647 [inline]
> >         console_unlock+0x516/0x1040 kernel/printk/printk.c:2452
> >         vprintk_emit+0x370/0x960 kernel/printk/printk.c:1978
> >         vprintk_default+0x28/0x30 kernel/printk/printk.c:2005
> >         vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:398
> >         printk+0xba/0xed kernel/printk/printk.c:2038
> >         report_bug.cold+0x11/0x5e lib/bug.c:191
> >         fixup_bug arch/x86/kernel/traps.c:178 [inline]
> >         fixup_bug arch/x86/kernel/traps.c:173 [inline]
> >         do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:271
> >         do_invalid_op+0x37/0x50 arch/x86/kernel/traps.c:290
> >         invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:973
> >         __ClearPageBuddy include/linux/page-flags.h:706 [inline]
>
> So that's VM_BUG_ON_PAGE(!Page##uname(page), page); in
> __ClearPage##uname, so another problem with !PageBuddy.
>
> >         rmv_page_order mm/page_alloc.c:744 [inline]
> >         rmv_page_order mm/page_alloc.c:742 [inline]
> >         __isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3134
>
> But this is later in the function than the first BUG_ON, so something
> has raced with us?
>
> Also two kcompactd crashes with slightly different stacktraces, that
> would have to be a NUMA system with multiple kcompactd's?
>
> >         fast_isolate_freepages mm/compaction.c:1356 [inline]
> >         isolate_freepages mm/compaction.c:1429 [inline]
> >         compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
> >         unmap_and_move mm/migrate.c:1177 [inline]
> >         migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
> >         compact_zone+0x2207/0x3e90 mm/compaction.c:2173
> >         kcompactd_do_work+0x6de/0x1200 mm/compaction.c:2564
> >         kcompactd+0x251/0x970 mm/compaction.c:2657
> >         kthread+0x357/0x430 kernel/kthread.c:247
> >         ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/e4cb6380-b462-857e-3219-319fdbfa6f81%40suse.cz.
> For more options, visit https://groups.google.com/d/optout.

