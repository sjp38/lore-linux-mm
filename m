Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C165EC00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 23:13:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4823D218AC
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 23:13:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fsSUR5RJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4823D218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 933818E0003; Wed, 27 Feb 2019 18:13:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E1728E0001; Wed, 27 Feb 2019 18:13:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F74B8E0003; Wed, 27 Feb 2019 18:13:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 541148E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:13:47 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id 42so8784268otv.5
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 15:13:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L4iB1TAi1pjz4TkszZs5W6ySbQ0hKBMhkCQJIJuMGUc=;
        b=SCmifNwWrDSMGzrOgsCCysI7kuSUa7Qr8cs8NnqrD1S6NxAgWDouecxo94OsD5ZUrQ
         XZFgFEd0BEconOFUhvEs24MACMLvk8uzr1auW+knd6N0xkfL/ARzjccPLUrHSExEe96X
         tP/QwoEnBOXb9f8QzCI8kTzJmMLqRkENLMSfEZfKyVRZyN/RmhMcj+TQfJpkTQcu/ENG
         kv95NIJM469w+829ZbkGJcbSQM06fWWHRBIdPp5bB+V0Dqq0FzGyh6YLoPaKYFHFuVco
         ccZIQbAGHsuZ03uxl0c0kOMWSUBqL9a/0n0jREXnKp3uwdzHS+7EU6c86mLW1Oogjd4v
         8aZw==
X-Gm-Message-State: AHQUAuYF8MoD8oJ2OMAb2S7ggr3TcsXG5BOgA9lCn8WYe3lzZvG2XTWe
	Zi10vdd8DlqejxDkQ5oJZ+186hgUBnE1FVXMVItywNO8Yr0n+Hf8uMkD1G7sTYpnkvtKlN1001c
	3f/9jNGJwsb8SnD1+yMZVl52B9M6yt2X8wHXrKkMHhywatgZrvuAHvDeax+gHl0ZXM/VC9n2n3W
	GdkXPN+xam6vEqzldE/vmXGSgym+6g/0LYQD6SMhkJUFL3P3s1POBjwtvbm1pnuhprQS+rmvsmL
	l8ef95rRACujRNYiVmlz3mE54+d04M/A6qEU5G6iUebg+i634ZJ7o/M0Bp05o/sYOwBrK3zbYhV
	TwOlLFQV4KA7KnP5HwVQuQxEfhFvH+kKALHBKM1rAYIbW5dygQkeR2qcHm7IQVnubistBOW3j71
	t
X-Received: by 2002:aca:b886:: with SMTP id i128mr1155931oif.65.1551309226866;
        Wed, 27 Feb 2019 15:13:46 -0800 (PST)
X-Received: by 2002:aca:b886:: with SMTP id i128mr1155890oif.65.1551309225607;
        Wed, 27 Feb 2019 15:13:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551309225; cv=none;
        d=google.com; s=arc-20160816;
        b=JXNTdZSjCCFC63jcfcPadCq7iBpxNkm92Toa7rtraQIC/CY1Ual7fvbT21MHFdTgJO
         eTSbJE8mit1z+qyUSDA2Z1DkPYrEc+UD1KvPLDeUJB2vzIYz+3eP/SMXFeHJiDvWLsxP
         Q5du/mjetAsInysaE/tVed1TrkGFz6ObYowhts9LLbzsQcJnRfwhmblGnztmQ/q38gVO
         u23ooJIbMYJHFesAyYFBkdHiZBrf2zxtyYioG0JBe12C7Wlzil4UVXMBn8Wuf/6IPDsa
         8KXi5qNGEEGoD9qFTbhPB+JtJ+bAaF3uX3gaYQ1TYjNHCOQlj5m3fQfzVOgeIusw9tYE
         6Ewg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L4iB1TAi1pjz4TkszZs5W6ySbQ0hKBMhkCQJIJuMGUc=;
        b=hvqUgIkcWBK9Lz2aPachT4qhF42eEoE6mA6ByZ9/lK74afhqn/WZxaS3kaJB0U9TFO
         Ngr1Z6cCZ9AoTLJ3Vq1kPP2fu0/xxfq/xsxKCWF1aKjmyuE9Zi9+g/YBNQYrju2vMxR+
         ax+uQ33QlLIO0A0RJ34u76qieEo5zGZUklP+U9ANCALyxiRz9w1YwZZk+FUyojDydw7h
         dauZV9bTWX/wGIZuIyyM7XvakOlP+rwMW0DzM/+2L6RsHKt0KLB/4ztMbd8Qw+NwJ0z2
         MIDmZEnqQizrENrRDnaByS2RhjfHSnLlkXSIebokS/iSxnC+fUo+NvJPt7gxlEDfrDOw
         mnOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fsSUR5RJ;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor8969243otl.139.2019.02.27.15.13.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 15:13:45 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fsSUR5RJ;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L4iB1TAi1pjz4TkszZs5W6ySbQ0hKBMhkCQJIJuMGUc=;
        b=fsSUR5RJY0DQyV9cFLRSEosDP6TW6DQMsXEZ7bwqXNohhqgk5FoRjbvr/GWCmkRgLA
         gXCuCy9RP8RnjmXq894u+AtUOtlJN61RYpAFRZSKai50R+ZFj8B1aw3kmy4lA1YuakRs
         MJDTLo4h/bd4ZYe/yuZlf4VFFKtClDMfo07Zpkq7o4m/eYL0GOmYEvwSQOpkf0VrmeiG
         c9z8gYkBrAKBvRHwea4Zi9YgkaVT0FOdZv449224ouGDZNvgS8rj+rWJLeWKPM5600Fh
         omsDJWQTOH1hSDJ0Aq6JpXTYXSEiML7tDppibpKGgyYSs/aO+tB0AIKDjh/rp3VZ2Djd
         SsZQ==
X-Google-Smtp-Source: AHgI3Ibq3INcvdSZ6hrRftj+JBEGRtfHRUA+pGXaG2Kpvqs5I5mGjH4T/w7Vz6cZQq//KsYiqJN46/66+r+jTuHSthc=
X-Received: by 2002:a9d:66d0:: with SMTP id t16mr3861820otm.35.1551309224822;
 Wed, 27 Feb 2019 15:13:44 -0800 (PST)
MIME-Version: 1.0
References: <0000000000001aab8b0582689e11@google.com> <20190221113624.284fe267e73752639186a563@linux-foundation.org>
In-Reply-To: <20190221113624.284fe267e73752639186a563@linux-foundation.org>
From: Jann Horn <jannh@google.com>
Date: Thu, 28 Feb 2019 00:13:18 +0100
Message-ID: <CAG48ez14jBF3uJH8qP+JrXtiQnQ2S+y9wHVpQ0mEXbmAVqKgWg@mail.gmail.com>
Subject: missing stack trace entry on NULL pointer call [was: Re: BUG: unable
 to handle kernel NULL pointer dereference in __generic_file_write_iter]
To: Andrew Morton <akpm@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>
Cc: syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>, 
	amir73il@gmail.com, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	Dave Chinner <david@fromorbit.com>, hannes@cmpxchg.org, Hugh Dickins <hughd@google.com>, 
	jrdr.linux@gmail.com, kernel list <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	"the arch/x86 maintainers" <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Josh for unwinding, +x86 folks

On Wed, Feb 27, 2019 at 11:43 PM Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 21 Feb 2019 06:52:04 -0800 syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com> wrote:
>
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
> > dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
>
> Not understanding.  That seems to be saying that we got a NULL pointer
> deref in __generic_file_write_iter() at
>
>                 written = generic_perform_write(file, from, iocb->ki_pos);
>
> which isn't possible.
>
> I'm not seeing recent changes in there which could have caused this.  Help.

+

Maybe the problem is that the frame pointer unwinder isn't designed to
cope with NULL function pointers - or more generally, with an
unwinding operation that starts before the function's frame pointer
has been set up?

Unwinding starts at show_trace_log_lvl(). That begins with
unwind_start(), which calls __unwind_start(), which uses
get_frame_pointer(), which just returns regs->bp. But that frame
pointer points to the part of the stack that's storing the address of
the caller of the function that called NULL; the caller of NULL is
skipped, as far as I can tell.

What's kind of annoying here is that we don't have a proper frame set
up yet, we only have half a stack frame (saved RIP but no saved RBP).

> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com
> >
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> > #PF error: [INSTR]
> > PGD a7ea0067 P4D a7ea0067 PUD 81535067 PMD 0
> > Oops: 0010 [#1] PREEMPT SMP KASAN
> > CPU: 0 PID: 15924 Comm: syz-executor0 Not tainted 5.0.0-rc4+ #50
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: 0010:          (null)
> > Code: Bad RIP value.
> > RSP: 0018:ffff88804c3d7858 EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: ffffffff885aeb60 RCX: 000000000000005b
> > RDX: 0000000000000000 RSI: ffff88807ec22930 RDI: ffff8880a59bdcc0
> > RBP: ffff88804c3d79b8 R08: 0000000000000000 R09: ffff88804c3d7910
> > R10: ffff8880835ca200 R11: 0000000000000000 R12: 000000000000005b
> > R13: ffff88804c3d7c98 R14: dffffc0000000000 R15: 0000000000000000
> > FS:  00007f3456db4700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: ffffffffffffffd6 CR3: 00000000814ac000 CR4: 00000000001406f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > Call Trace:
> >   __generic_file_write_iter+0x25e/0x630 mm/filemap.c:3333
> >   ext4_file_write_iter+0x37a/0x1410 fs/ext4/file.c:266
> >   call_write_iter include/linux/fs.h:1862 [inline]
> >   new_sync_write fs/read_write.c:474 [inline]
> >   __vfs_write+0x764/0xb40 fs/read_write.c:487
> >   vfs_write+0x20c/0x580 fs/read_write.c:549
> >   ksys_write+0x105/0x260 fs/read_write.c:598
> >   __do_sys_write fs/read_write.c:610 [inline]
> >   __se_sys_write fs/read_write.c:607 [inline]
> >   __x64_sys_write+0x73/0xb0 fs/read_write.c:607
> >   do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
> >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > RIP: 0033:0x458089
> > Code: 6d b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7
> > 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff
> > ff 0f 83 3b b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> > RSP: 002b:00007f3456db3c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> > RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000458089
> > RDX: 000000000000005b RSI: 0000000020000240 RDI: 0000000000000003
> > RBP: 000000000073bf00 R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000246 R12: 00007f3456db46d4
> > R13: 00000000004c7450 R14: 00000000004dce68 R15: 00000000ffffffff
> > Modules linked in:
> > CR2: 0000000000000000
> > ---[ end trace 5cac9d2c75a59916 ]---
> > kobject: 'loop5' (000000004426a409): kobject_uevent_env
> > RIP: 0010:          (null)
> > Code: Bad RIP value.
> > RSP: 0018:ffff88804c3d7858 EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: ffffffff885aeb60 RCX: 000000000000005b
> > kobject: 'loop5' (000000004426a409): fill_kobj_path: path
> > = '/devices/virtual/block/loop5'
> > RDX: 0000000000000000 RSI: ffff88807ec22930 RDI: ffff8880a59bdcc0
> > kobject: 'loop2' (00000000b82e0c58): kobject_uevent_env
> > kobject: 'loop2' (00000000b82e0c58): fill_kobj_path: path
> > = '/devices/virtual/block/loop2'
> > RBP: ffff88804c3d79b8 R08: 0000000000000000 R09: ffff88804c3d7910
> > R10: ffff8880835ca200 R11: 0000000000000000 R12: 000000000000005b
> > R13: ffff88804c3d7c98 R14: dffffc0000000000 R15: 0000000000000000
> > kobject: 'loop5' (000000004426a409): kobject_uevent_env
> > FS:  00007f3456db4700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> > kobject: 'loop5' (000000004426a409): fill_kobj_path: path
> > = '/devices/virtual/block/loop5'
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00000000022029a0 CR3: 00000000814ac000 CR4: 00000000001406f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >
> >
> > ---
> > This bug is generated by a bot. It may contain errors.
> > See https://goo.gl/tpsmEJ for more information about syzbot.
> > syzbot engineers can be reached at syzkaller@googlegroups.com.
> >
> > syzbot will keep track of this bug report. See:
> > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > syzbot.
>

