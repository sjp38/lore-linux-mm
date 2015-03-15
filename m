Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C51566B0078
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 13:34:31 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so23236687wgd.2
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 10:34:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pi10si13276487wic.66.2015.03.15.10.34.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Mar 2015 10:34:30 -0700 (PDT)
Message-ID: <1426440863.28068.103.camel@stgolabs.net>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
 serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sun, 15 Mar 2015 10:34:23 -0700
In-Reply-To: <20150315170521.GA2278@moon>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
	 <20150315142137.GA21741@redhat.com>
	 <1426431270.28068.92.camel@stgolabs.net>
	 <20150315152652.GA24590@redhat.com>
	 <1426434125.28068.100.camel@stgolabs.net> <20150315170521.GA2278@moon>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, "Michael
 Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>

On Sun, 2015-03-15 at 20:05 +0300, Cyrill Gorcunov wrote:
> On Sun, Mar 15, 2015 at 08:42:05AM -0700, Davidlohr Bueso wrote:
> > > > > Yes, this code needs cleanups, I agree. Does this series makes it better?
> > > > > To me it doesn't, and the diffstat below shows that it blows the code.
> > > >
> > > > Looking at some of the caller paths now, I have to disagree.
> > > 
> > > And I believe you are wrong. But let me repeat, I leave this to Cyrill
> > > and Konstantin. Cleanups are always subjective.
> > > 
> > > > > In fact, to me it complicates this code. For example. Personally I think
> > > > > that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.
> > > >
> > > > How could you remove this?
> > > 
> > > Just remove this flag and the test_and_set_bit(MMF_EXE_FILE_CHANGED) check.
> > > Again, this is subjective, but to me it looks ugly. Why do we allow to
> > > change ->exe_file but only once?
> 
> This came from very first versions of the functionality implemented
> in prctl. It supposed to help sysadmins to notice if there exe
> transition happened. As to me it doesn't bring much security, if I
> would be a virus I would simply replace executing code with ptrace
> or via other ways without telling outside world that i've changed
> exe path. That said I would happily rip off this MMF_EXE_FILE_CHANGED
> bit but I fear security guys won't be that happy about it.
> (CC'ing Kees)

Also adding Michael for any prctl manpage and api changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
