Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4FDFC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BAAC2085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:54:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rtzlD+QI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BAAC2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A1C78E0003; Thu, 28 Feb 2019 19:54:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 129D18E0001; Thu, 28 Feb 2019 19:54:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F35998E0003; Thu, 28 Feb 2019 19:54:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id C375F8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:54:33 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id 66so2847124otl.23
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:54:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8mgdYbmYAMxrxPxkrDEDYUV9PcZHWAxATjOJ8ZwA2PY=;
        b=nf7izTQjjQl5569aYm/LWB0pusOCUCQYrSuqdU8+MiRzNKYAwgPxq2ak0aIAxZsHYx
         vMBNiwQ4ChNrJ55Eaz5oK21Ck8jzvDAv7XZ+PwKjmXHCXKFbmTKWJkO7Fyk09RtUfWzx
         Bo6c0DoMY9t1yO8kBuxHyUazcYw59GX/BMI5oB5joPff08KkA3rRJRoXmlza+RbvaWgZ
         4okeYA4w1HEykf4G4tm46t6ZeUtZTohw05n9aajweAdps4m0c3/4MSsekXNCXRrPjx6K
         efoJixuI6xSeDPi+w0bi6N55OmRsaiuX5907hknMiiBR0JsoiZeRS2Oxa15scftuN8H4
         VZrQ==
X-Gm-Message-State: AHQUAub91sm3HLpthnwNW0CMix8Pr2lKoGDkRlr3mgwM+rbwlhmauyxP
	pMBL4nY8Fqwv+ofoB77eMwdO3+hkB/LDFh4azV1+NVOyLg205jkGi/xzenQHRkg1InLklWJORjX
	x+YY32ssmahN1o3q2Mk2mx+k/HjFFMsesmp2fm/lQJBP06btO6OidKcyCgV3n5bTBNUaLP13bUr
	7o9S6IQtvVDHsoRQM9zass1NYvFJpw2Cuko7gaTMCDA8aAme78hs5etPEiwBIW1rW9GZUXnM4pH
	m6+EJoBo2Yaw7NPSK8If0esvdiwyxdaukZZwsUgi83NRWK8pvCYqiWlTdIviwG4WoReug35cGzB
	mTzNhoWK2cwatf5SFtqRKXSpOzFsAtQs9kOw7GBk2X1gz34PlKMGrAg43W/HDQcH3S0z7dFVwuf
	o
X-Received: by 2002:aca:e5c9:: with SMTP id c192mr1623783oih.118.1551401673242;
        Thu, 28 Feb 2019 16:54:33 -0800 (PST)
X-Received: by 2002:aca:e5c9:: with SMTP id c192mr1623757oih.118.1551401672332;
        Thu, 28 Feb 2019 16:54:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551401672; cv=none;
        d=google.com; s=arc-20160816;
        b=HcDSk4+5OGXI7jMPNuZi1afkSY71oRgTzv4M0W5YnmDmhyrEqAY0P09AI5U6e8iPc+
         8o3IT23GhEgSpxa0RbKDbpXUfnDnemnSSwCpnBYmwsnlGrJEQ3RR/SugsfW6mmEU4Y+v
         JB4uobGtJuV/S3xilpsFiOuMMG2+LdVjKPxkNaM/BQyMw88e0KCqNWaGSD5PH4Ln8HYa
         dfQ/dqGpGhxcLLN3M396YlirQp0nkwY29m4OcBSqlK0roV8V6qg5rMjnEBn9ZdStMcJC
         PpnPxT1nUK83532n3IOkXPqn2GGULTtJXfpcl8WZtEWzYy2JFyBvCOaScOJGORxHdEuD
         IscQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8mgdYbmYAMxrxPxkrDEDYUV9PcZHWAxATjOJ8ZwA2PY=;
        b=hvgB+wIyIgTG2VXkcCSvi/9KDQoG4mCoACQt6xZj6gz4vx/OfskN9XQQshUkqqmiXG
         f/NSxvL5IvyG+jsOZDMTDfQp1nhiISVOpD/c7AdPU22eyNj+kialhsEHAhaGnqFVe6Gx
         /hVmR1IhJGHKXDcHFjHex/WWNQfUbDJNsQFUDpWhcrihNnorchgYG5QmCAtVoxzP7zFQ
         Q/PKso6mVSa55SIpt8aDdwRJSJsjqhvTt+qE9feEFujCMb3//9n1Qv8myr8qGv04t+y9
         XL5OBHTsHTkf7YnCVzRv57ZkUMRealeLtfANjGBWywZjKHk5o6n295NYA9s4IJVbhVU3
         ZV4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rtzlD+QI;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j125sor7940122oif.73.2019.02.28.16.54.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 16:54:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rtzlD+QI;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8mgdYbmYAMxrxPxkrDEDYUV9PcZHWAxATjOJ8ZwA2PY=;
        b=rtzlD+QIneyB0PN0/wgylHtsOTlKgeP3E3qAfQguv23CnsMgcECXL4G0Hp7A22axRA
         oyKxrcV04W/FJ9UBx6qSMDHArEwGtBfnfMloqqdXKB9LBug439hCANVLXzLZo7b1I8Ic
         +NRtDNaAWwHg1IZbnnMIZz38amNeU2ZrJMyHR73AKgAu98R41bDTMkfZFrxuvOq5xXN5
         +pEHxDgNvuVcPCkqwQZ9VKnWnR9SemLGg2aHUPg3HtIO2NqFxj1azIf5KXhcg9Rwp4Cd
         CVYwjpt2y28NiFsC9I8RBIueBYv+KdeI5CYJtmjsBi4QMjqxqTT2JtPJM1ExEZ/+DGbA
         rGsA==
X-Google-Smtp-Source: AHgI3IbqmUIfqsBaoYBqvf3sGrxahpjE8Ht9DkwYj1SzEI7fYaiAtXazN0U6LPuX6kQ/WbrLUNQ/Fefg91mnRKoD4EI=
X-Received: by 2002:aca:cc4d:: with SMTP id c74mr1689814oig.157.1551401671766;
 Thu, 28 Feb 2019 16:54:31 -0800 (PST)
MIME-Version: 1.0
References: <0000000000001aab8b0582689e11@google.com> <20190221113624.284fe267e73752639186a563@linux-foundation.org>
 <CAG48ez14jBF3uJH8qP+JrXtiQnQ2S+y9wHVpQ0mEXbmAVqKgWg@mail.gmail.com>
 <alpine.DEB.2.21.1902281248400.1821@nanos.tec.linutronix.de> <CAG48ez2huzOwKvH5qVGaGeWOKRDX8qr_9keHBcZCyBaw85ed-g@mail.gmail.com>
In-Reply-To: <CAG48ez2huzOwKvH5qVGaGeWOKRDX8qr_9keHBcZCyBaw85ed-g@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Fri, 1 Mar 2019 01:54:05 +0100
Message-ID: <CAG48ez3UdLSikuCqEUnVJH3wVRjj95fzO-3HUO7=5bkaftd3jw@mail.gmail.com>
Subject: Re: missing stack trace entry on NULL pointer call [was: Re: BUG:
 unable to handle kernel NULL pointer dereference in __generic_file_write_iter]
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>, 
	Amir Goldstein <amir73il@gmail.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	Dave Chinner <david@fromorbit.com>, hannes@cmpxchg.org, Hugh Dickins <hughd@google.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, kernel list <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	"the arch/x86 maintainers" <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 5:34 PM Jann Horn <jannh@google.com> wrote:
>
> On Thu, Feb 28, 2019 at 1:57 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Thu, 28 Feb 2019, Jann Horn wrote:
> > > +Josh for unwinding, +x86 folks
> > > On Wed, Feb 27, 2019 at 11:43 PM Andrew Morton
> > > <akpm@linux-foundation.org> wrote:
> > > > On Thu, 21 Feb 2019 06:52:04 -0800 syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com> wrote:
> > > >
> > > > > Hello,
> > > > >
> > > > > syzbot found the following crash on:
> > > > >
> > > > > HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
> > > > > git tree:       upstream
> > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
> > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
> > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
> > > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > >
> > > > > Unfortunately, I don't have any reproducer for this crash yet.
> > > >
> > > > Not understanding.  That seems to be saying that we got a NULL pointer
> > > > deref in __generic_file_write_iter() at
> > > >
> > > >                 written = generic_perform_write(file, from, iocb->ki_pos);
> > > >
> > > > which isn't possible.
> > > >
> > > > I'm not seeing recent changes in there which could have caused this.  Help.
> > >
> > > +
> > >
> > > Maybe the problem is that the frame pointer unwinder isn't designed to
> > > cope with NULL function pointers - or more generally, with an
> > > unwinding operation that starts before the function's frame pointer
> > > has been set up?
> > >
> > > Unwinding starts at show_trace_log_lvl(). That begins with
> > > unwind_start(), which calls __unwind_start(), which uses
> > > get_frame_pointer(), which just returns regs->bp. But that frame
> > > pointer points to the part of the stack that's storing the address of
> > > the caller of the function that called NULL; the caller of NULL is
> > > skipped, as far as I can tell.
> > >
> > > What's kind of annoying here is that we don't have a proper frame set
> > > up yet, we only have half a stack frame (saved RIP but no saved RBP).
> >
> > That wreckage is related to the fact that the indirect calls are going
> > through __x86_indirect_thunk_$REG. I just verified on a VM with some other
> > callback NULL'ed that the resulting backtrace is not really helpful.
> >
> > So in that case generic_perform_write() has two indirect calls:
> >
> >   mapping->a_ops->write_begin() and ->write_end()
>
> Does the indirect thunk thing really make any difference? When you
> arrive at RIP=NULL, RSP points to a saved instruction pointer, just
> like when indirect calls are compiled normally.
>
> I just compiled kernels with artificial calls to a NULL function
> pointer (in prctl_set_seccomp()), with retpoline disabled, with both
> unwinders. The ORC unwinder shows a call trace with "?" everywhere
> that doesn't show the caller:
[...]
> So I think this doesn't really have anything to do with
> __x86_indirect_thunk_$REG, and the best possible fix might be to teach
> the unwinders that RIP==NULL means "pretend that RIP is *real_RSP and
> that RSP is real_RSP+8, and report *real_RSP as the first element of
> the backtrace".

Cooking up some patches now...

