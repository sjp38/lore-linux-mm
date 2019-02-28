Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19446C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:34:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA10C218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:34:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IrwZj+lP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA10C218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561128E000A; Thu, 28 Feb 2019 11:34:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 537D28E0001; Thu, 28 Feb 2019 11:34:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44E288E000A; Thu, 28 Feb 2019 11:34:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0138E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:34:45 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id s12so9866445oth.14
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:34:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qV6so+2cJ5Mp79WGjjYmoMCFVVKG+rLQnGEKE53at8Q=;
        b=UKe9m+KIGrH4JvO14LbqcEUuOI8fhzJR89AMRD81hxJqbLYvcwYMmMY1YzuSdpRcgn
         id/ROgNByTaXAZw3TyMIT0UlhuHVSqymZSE9hhPuWrl3WV09RQejyU8jBpXodlI+JnVt
         xStFTiq8B2UzfHyIv8Ncd6nqbsm0LTg5uJZIEJDeTGoHhdsYI0GXVdLfW2Eu3Gcx430Y
         /FrXeZDcBzw+zK47RFwUZuOmNXv+OrNh38OJTVq0uM/4oi7LygYZ+Tv96Kz1Ix6ju9KI
         tsNwdDDLoKSSnbWaHyzuXzMtCvKZzAOZSqVBFMlBNhnwDIitHRWzxairE+UI2B9DIvlW
         niNQ==
X-Gm-Message-State: AHQUAuYJLESVGuExVahwigunlG4CDM39sLn1yGr/uVlHaoNVSjDFRUnh
	H0OkUPFgqUX7VjcIuvYRIqstjU8tih68lWSRgGVsNush2WhFhwYPmuOQHCR2yHfz557oAyLa1UY
	ierZdQqXzG4a/rmFq1MCMqyBL+3c3ST9z/YsKd8TRPZR8ZPAGRr5HEWfgotA6wyEE+BQEBHcc9a
	l8xalRJRSNQthpl4Pr1VGpI/JVFJVzU2j5VLFKmp5zfhi2cYJLgUhhrqee83NW6fk1+Ov5qV7OJ
	it0RFQeBRW0Bb03QB5iRjjgd1XMWEEgIc8n2ErBOE5Q9h1UW10Uy+8vd3epTBbNaYcf6KWEuuHC
	bEJOd3SIWT26CIGjZNOVseLlRRbfeY4Zu0IL1S0W/qvXxofiFuSV5YOgjGmSTiwxfWflI/pw7c8
	h
X-Received: by 2002:aca:4911:: with SMTP id w17mr382023oia.36.1551371684653;
        Thu, 28 Feb 2019 08:34:44 -0800 (PST)
X-Received: by 2002:aca:4911:: with SMTP id w17mr381962oia.36.1551371683378;
        Thu, 28 Feb 2019 08:34:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371683; cv=none;
        d=google.com; s=arc-20160816;
        b=Kkm0isEWnftOS+CHhJNcY94GVeVRQZgv4iFDWxB8PK7h0VevWfDy3Gzjy0qcqSqe+I
         liyRR3TIVCMSBTP+A0/hJR2jnzJdOoM1phl4k1S/vMAuJgU2O0jKxjqvlgKoNRDD/SS7
         A2r5XcS6tnQCdzmqumId6XtV7HGj3u9aYOh2YhA4zuVzbzYJzbCkwJ4+5elxHiPRYO6H
         /rJv2LP1amBMK//pNghlqo3VBYC70tUFFd6gNI+m9KWe6hZIh8SmeqQjCe/rQiasm4xN
         gl8kiA9MGH7i96yP9spCaWywohmx7X1w8yupuByQ0YOtJpTClsfLobn7w8EWOPGcJMO7
         pBIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qV6so+2cJ5Mp79WGjjYmoMCFVVKG+rLQnGEKE53at8Q=;
        b=uX7S+8bNDvm4I02fvAdHaSb8P0hXcL3zzSl5xRyBF8v8K+z8UDH0vqPgc/o4fzEHQ3
         xUYUQQCfEiua2Od7hcYrm0l6Lf5TlEj4zV8oCyHK+lBG1m9IuKXm5tQjZtt3T3CXdUeJ
         7QWOFWKTzWx1jjjVLi2JsCCbRaQ9GK+0HXEC6xewaF6r571L3pnYLAqehT+hcc7P5/6Z
         7U6Igp/NSez+LizFH9fSwwB9P5k2sg9MJHlY99R4X0aTGPbzo9nWnNOx/nFuMtfRwv4x
         /gCQe/DMEPIxgRazzQNFNkfuSYg321UYoKixLgnY2NJVE2NkqQqvD1AtuA+9tQyYnVws
         mUtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IrwZj+lP;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d19sor11463844otp.181.2019.02.28.08.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:34:43 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IrwZj+lP;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qV6so+2cJ5Mp79WGjjYmoMCFVVKG+rLQnGEKE53at8Q=;
        b=IrwZj+lPvOuvc8PR+mbu51hAu5fkyZMm3nz2FHP38WND5OcYLE2oLJiCpmpdSyYkOt
         L9GN85sf/RAJuZfmZVaWgrPjvY273EnJ10a8bslhakscSfmTLkOeLf2fAmA6BE11NCWt
         oRaaq3KhcNT/0Prrw2kKL07LcVTD51iAUSuhS9avOeqDgLdlP3u2LIkaWqt+Ebrh/aWS
         DgAXneTIhfn/eSg51sxN/u1CICVYRbxC8dV8jktILScKUenOaLcc9fG3D0/FzG6vauDl
         eOLOlwSqWiDZ8Y6Mmrm4v/3HakTY5MbkXZ5Pz+g5jXqa4WoXNJBShv8ZDBOvT/OmS/K3
         1fgg==
X-Google-Smtp-Source: APXvYqydEovJ4GD5C/IHzu3C21fcJ8PnJIuJroPrp9Db44kNZfaEZP4G3E5X0wDJ47+Qe6d2BOgQf4MGpxJw0ORmGHs=
X-Received: by 2002:a9d:6c84:: with SMTP id c4mr311118otr.242.1551371682619;
 Thu, 28 Feb 2019 08:34:42 -0800 (PST)
MIME-Version: 1.0
References: <0000000000001aab8b0582689e11@google.com> <20190221113624.284fe267e73752639186a563@linux-foundation.org>
 <CAG48ez14jBF3uJH8qP+JrXtiQnQ2S+y9wHVpQ0mEXbmAVqKgWg@mail.gmail.com> <alpine.DEB.2.21.1902281248400.1821@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1902281248400.1821@nanos.tec.linutronix.de>
From: Jann Horn <jannh@google.com>
Date: Thu, 28 Feb 2019 17:34:16 +0100
Message-ID: <CAG48ez2huzOwKvH5qVGaGeWOKRDX8qr_9keHBcZCyBaw85ed-g@mail.gmail.com>
Subject: Re: missing stack trace entry on NULL pointer call [was: Re: BUG:
 unable to handle kernel NULL pointer dereference in __generic_file_write_iter]
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>, amir73il@gmail.com, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, hannes@cmpxchg.org, 
	Hugh Dickins <hughd@google.com>, jrdr.linux@gmail.com, 
	kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>, 
	Jan Kara <jack@suse.cz>, "the arch/x86 maintainers" <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 1:57 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> On Thu, 28 Feb 2019, Jann Horn wrote:
> > +Josh for unwinding, +x86 folks
> > On Wed, Feb 27, 2019 at 11:43 PM Andrew Morton
> > <akpm@linux-foundation.org> wrote:
> > > On Thu, 21 Feb 2019 06:52:04 -0800 syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com> wrote:
> > >
> > > > Hello,
> > > >
> > > > syzbot found the following crash on:
> > > >
> > > > HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
> > > > git tree:       upstream
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
> > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > >
> > > > Unfortunately, I don't have any reproducer for this crash yet.
> > >
> > > Not understanding.  That seems to be saying that we got a NULL pointer
> > > deref in __generic_file_write_iter() at
> > >
> > >                 written = generic_perform_write(file, from, iocb->ki_pos);
> > >
> > > which isn't possible.
> > >
> > > I'm not seeing recent changes in there which could have caused this.  Help.
> >
> > +
> >
> > Maybe the problem is that the frame pointer unwinder isn't designed to
> > cope with NULL function pointers - or more generally, with an
> > unwinding operation that starts before the function's frame pointer
> > has been set up?
> >
> > Unwinding starts at show_trace_log_lvl(). That begins with
> > unwind_start(), which calls __unwind_start(), which uses
> > get_frame_pointer(), which just returns regs->bp. But that frame
> > pointer points to the part of the stack that's storing the address of
> > the caller of the function that called NULL; the caller of NULL is
> > skipped, as far as I can tell.
> >
> > What's kind of annoying here is that we don't have a proper frame set
> > up yet, we only have half a stack frame (saved RIP but no saved RBP).
>
> That wreckage is related to the fact that the indirect calls are going
> through __x86_indirect_thunk_$REG. I just verified on a VM with some other
> callback NULL'ed that the resulting backtrace is not really helpful.
>
> So in that case generic_perform_write() has two indirect calls:
>
>   mapping->a_ops->write_begin() and ->write_end()

Does the indirect thunk thing really make any difference? When you
arrive at RIP=NULL, RSP points to a saved instruction pointer, just
like when indirect calls are compiled normally.

I just compiled kernels with artificial calls to a NULL function
pointer (in prctl_set_seccomp()), with retpoline disabled, with both
unwinders. The ORC unwinder shows a call trace with "?" everywhere
that doesn't show the caller:

[  228.219140] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000000
[  228.223897] #PF error: [INSTR]
[  228.224562] PGD 0 P4D 0
[  228.225119] Oops: 0010 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[  228.226319] CPU: 1 PID: 1099 Comm: artificial_null Not tainted
5.0.0-rc8+ #299
[  228.227818] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.10.2-1 04/01/2014
[  228.229542] RIP: 0010:          (null)
[  228.230331] Code: Bad RIP value.
[  228.231011] RSP: 0018:ffff8881d798fe88 EFLAGS: 00010246
[  228.232104] RAX: ffffffffffffffda RBX: 0000000000000016 RCX: ffffffffa0368205
[  228.233599] RDX: dffffc0000000000 RSI: 00007ffde0d71168 RDI: 0000000000000042
[  228.235077] RBP: 1ffff1103af31fd4 R08: 0000561b50807740 R09: 0000000000000016
[  228.236557] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000042
[  228.238039] R13: 0000000000000000 R14: 00007ffde0d71168 R15: 0000561b50807740
[  228.239517] FS:  00007fe31f1cf700(0000) GS:ffff8881eb040000(0000)
knlGS:0000000000000000
[  228.241213] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  228.242411] CR2: ffffffffffffffd6 CR3: 00000001df8b8004 CR4: 0000000000360ee0
[  228.243886] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  228.245364] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  228.246841] Call Trace:
[  228.247366]  ? __x64_sys_prctl+0x402/0x680
[  228.248224]  ? __ia32_sys_prctl+0x6e0/0x6e0
[  228.249106]  ? __do_page_fault+0x457/0x620
[  228.249969]  ? do_syscall_64+0x6d/0x160
[  228.250778]  ? entry_SYSCALL_64_after_hwframe+0x44/0xa9
[...]

whereas the FP unwinder shows this, listing prctl_set_seccomp only
with a question mark:

[   47.469957] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000000
[   47.476973] #PF error: [INSTR]
[   47.477742] PGD 0 P4D 0
[   47.478341] Oops: 0010 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[   47.479703] CPU: 4 PID: 1079 Comm: artificial_null Not tainted
5.0.0-rc8+ #300
[   47.481489] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.10.2-1 04/01/2014
[   47.483442] RIP: 0010:          (null)
[   47.484328] Code: Bad RIP value.
[   47.485085] RSP: 0018:ffff8881e01f7e70 EFLAGS: 00010246
[   47.486358] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: ffffffffafbf007a
[   47.488090] RDX: dffffc0000000000 RSI: 00007ffe164b4f28 RDI: 0000000000000042
[   47.489862] RBP: ffff8881e01f7e78 R08: 0000562942136740 R09: 0000000000000016
[   47.491491] R10: 0000000000000000 R11: 0000000000000000 R12: 1ffff1103c03efd3
[   47.493144] R13: 0000000000000042 R14: 00007ffe164b4f28 R15: 0000000000000016
[   47.494795] FS:  00007fa38b1d6700(0000) GS:ffff8881eb300000(0000)
knlGS:0000000000000000
[   47.496638] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   47.497981] CR2: ffffffffffffffd6 CR3: 00000001e0e4c006 CR4: 0000000000360ee0
[   47.499623] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   47.501252] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   47.502927] Call Trace:
[   47.503501]  ? prctl_set_seccomp+0x3a/0x50
[   47.504450]  __x64_sys_prctl+0x457/0x6f0
[   47.505349]  ? __ia32_sys_prctl+0x750/0x750
[   47.506352]  do_syscall_64+0x72/0x160
[   47.507214]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[...]

Looking back at the syzkaller report, the command line output
(https://syzkaller.appspot.com/x/log.txt?x=1101382f400000) has this:

[  375.092788] Call Trace:
[  375.095378]  ? generic_perform_write+0x2a0/0x6b0
[  375.100150]  ? add_page_wait_queue+0x480/0x480
[  375.104744]  ? current_time+0x1b0/0x1b0
[  375.108727]  ? generic_write_check_limits+0x380/0x380
[  375.113942]  ? ext4_file_write_iter+0x28b/0x1410
{some non-dmesg output here}
[  375.118711]  __generic_file_write_iter+0x25e/0x630
[  375.123714]  ext4_file_write_iter+0x37a/0x1410

The first entry with a question mark is *RSP, the real caller; that's
generic_perform_write(), as expected. The rest is probably just random
garbage that happened to still be on the stack. It looks like
syzkaller strips out trace elements with question marks in front.


So I think this doesn't really have anything to do with
__x86_indirect_thunk_$REG, and the best possible fix might be to teach
the unwinders that RIP==NULL means "pretend that RIP is *real_RSP and
that RSP is real_RSP+8, and report *real_RSP as the first element of
the backtrace".

