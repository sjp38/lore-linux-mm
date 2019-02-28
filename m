Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6A4DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:57:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FD55214D8
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:57:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FD55214D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 567908E0003; Thu, 28 Feb 2019 07:57:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 517E58E0001; Thu, 28 Feb 2019 07:57:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42D728E0003; Thu, 28 Feb 2019 07:57:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id E49F48E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:57:04 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id g19so3120839wmh.1
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:57:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=KjjzL2D4B1oYkzeAwm7cYAKt7rwemXqWNNYnqNg+CYQ=;
        b=dwzPADJRba5jpcPUms1JY+4yCy/EMk9NMbzpRIXSTZ3mtv+fmQllSbNbKYu0SIUOzh
         GQ7WHtBB+gRHr1eHGn+awgMXo5g7CYfwHWQtf6kbPO1lbE8D+omjwca0HfvOSfMDryY1
         co4j70mykkxnvlB4wdsPCJ+sheGPWe1CLEHjQrf7CJUCa7FMxkQl56SITNRcFit84qjz
         +QtrimacSmp8AFzpgjUJn/eXKOb88rPPDpcw1DhAtvEPBOLkgnw2ijPGpHdriQAAg1OH
         JU6A8LQqaHdcngxiqwyaZNUFf18GiEoyLRyaUnIur4MNOWxhUwKB/nqNNycgltVvMdx8
         dG/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVuLoZ4SxwIJEDbmEM7i4+Ks90ybC5qbNDnKoGQSbX7Hc0TXO4U
	H3K+XTLOo6S5I9MUGJW4DbhagS1oMZskO08Nke1F3pOOOfEHPuI912IbkFiWfIYzTlvVXnQgLPA
	raoSxM/xPOlcE6czbxGX9DgO63UtJhJGeR3vbUpfciolChfz1IrYIodgwsxHNxhcuKQ==
X-Received: by 2002:a5d:6346:: with SMTP id b6mr6382195wrw.118.1551358624453;
        Thu, 28 Feb 2019 04:57:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqxmKZTKtrwzKUWnMQ28seqPVJJZs2dpvcMbFX9uzt8yrXwrlYwRVbtGx7VXpF1Z38ghwF1c
X-Received: by 2002:a5d:6346:: with SMTP id b6mr6382129wrw.118.1551358623361;
        Thu, 28 Feb 2019 04:57:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551358623; cv=none;
        d=google.com; s=arc-20160816;
        b=xlBA+EnsBqMPV2c7d4QDABSezaAaAZNP03PUi4lvY8JYoZRorOT6XrCHTOF0JlmFet
         07Zj2QOpCZIfvgCSMieNOjygzB/vg5ws7xMzUjnLd5OXxyaIj1hmgIdYFlhpyRBcJ7lm
         dMgR1jUCy8fHtjTV7y4u38yuWvnN/iJvowF++khL0VYO42I+QvFKOdDbVpp/K+HJZjDB
         bvRMwu7UZaoZP3HaVkFj//3M+RQr40gbuNAfzutZ/cF5DzP4Fqk/v9W+CKV/SaEtY+o5
         LqA68heh2mFVwha/E/4ErtkpcTy9gi1ign/wF4HY8BAL/vWuNMzAbF1pCNxvrRUL8Y4W
         iRUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=KjjzL2D4B1oYkzeAwm7cYAKt7rwemXqWNNYnqNg+CYQ=;
        b=dYVvCLqxBUMNSO2yq3JHcLZ+357Bs7waVCpCv7JilH66qY+O5vjsd3wArN6VFy6oWg
         zdtcup4Y5FzlPe8D3inp76JFeTUTAKZq30/hpSRmNZii8RSdfJqGRDHLRuF26B0BELOY
         aGW+XqSFPwul30Qs5+goykaP/kiagRtiJQJpg4LJ2vXZFGlkQZsMxtmZ/FsSNmWHIraY
         u7k/JTwBM0vgbs1be+6ptURk1vsO6sRqMO6wLQ2tvl2bIqkB9xUl6ka/HxkTF26bKqj4
         v0vLW4R/v6mJ9l6R6bpsjt9dFGa3uXR2c9JoiBJFNRx1NUGooScZwsJY9Anmbhg0J8ZS
         edOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f77si2983484wme.16.2019.02.28.04.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 28 Feb 2019 04:57:03 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1gzLF6-0005UT-EO; Thu, 28 Feb 2019 13:56:52 +0100
Date: Thu, 28 Feb 2019 13:56:51 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
To: Jann Horn <jannh@google.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Josh Poimboeuf <jpoimboe@redhat.com>, 
    syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>, 
    amir73il@gmail.com, "Darrick J. Wong" <darrick.wong@oracle.com>, 
    Dave Chinner <david@fromorbit.com>, hannes@cmpxchg.org, 
    Hugh Dickins <hughd@google.com>, jrdr.linux@gmail.com, 
    kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
    syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
    Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
    the arch/x86 maintainers <x86@kernel.org>
Subject: Re: missing stack trace entry on NULL pointer call [was: Re: BUG:
 unable to handle kernel NULL pointer dereference in
 __generic_file_write_iter]
In-Reply-To: <CAG48ez14jBF3uJH8qP+JrXtiQnQ2S+y9wHVpQ0mEXbmAVqKgWg@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1902281248400.1821@nanos.tec.linutronix.de>
References: <0000000000001aab8b0582689e11@google.com> <20190221113624.284fe267e73752639186a563@linux-foundation.org> <CAG48ez14jBF3uJH8qP+JrXtiQnQ2S+y9wHVpQ0mEXbmAVqKgWg@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2019, Jann Horn wrote:
> +Josh for unwinding, +x86 folks
> On Wed, Feb 27, 2019 at 11:43 PM Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 21 Feb 2019 06:52:04 -0800 syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com> wrote:
> >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
> > > git tree:       upstream
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > >
> > > Unfortunately, I don't have any reproducer for this crash yet.
> >
> > Not understanding.  That seems to be saying that we got a NULL pointer
> > deref in __generic_file_write_iter() at
> >
> >                 written = generic_perform_write(file, from, iocb->ki_pos);
> >
> > which isn't possible.
> >
> > I'm not seeing recent changes in there which could have caused this.  Help.
> 
> +
> 
> Maybe the problem is that the frame pointer unwinder isn't designed to
> cope with NULL function pointers - or more generally, with an
> unwinding operation that starts before the function's frame pointer
> has been set up?
> 
> Unwinding starts at show_trace_log_lvl(). That begins with
> unwind_start(), which calls __unwind_start(), which uses
> get_frame_pointer(), which just returns regs->bp. But that frame
> pointer points to the part of the stack that's storing the address of
> the caller of the function that called NULL; the caller of NULL is
> skipped, as far as I can tell.
> 
> What's kind of annoying here is that we don't have a proper frame set
> up yet, we only have half a stack frame (saved RIP but no saved RBP).

That wreckage is related to the fact that the indirect calls are going
through __x86_indirect_thunk_$REG. I just verified on a VM with some other
callback NULL'ed that the resulting backtrace is not really helpful.

So in that case generic_perform_write() has two indirect calls:

  mapping->a_ops->write_begin() and ->write_end()

Thanks,

	tglx

