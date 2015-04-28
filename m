Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3A06B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:36:29 -0400 (EDT)
Received: by wizk4 with SMTP id k4so155526807wiz.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 13:36:29 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id bw17si40422988wjb.30.2015.04.28.13.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 13:36:28 -0700 (PDT)
Received: by widdi4 with SMTP id di4so43234047wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 13:36:27 -0700 (PDT)
Date: Tue, 28 Apr 2015 22:36:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Should mmap MAP_LOCKED fail if mm_poppulate fails?
Message-ID: <20150428203625.GA9664@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
 <20150428164302.GI2659@dhcp22.suse.cz>
 <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
 <20150428183535.GB30918@dhcp22.suse.cz>
 <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 28-04-15 11:38:35, Linus Torvalds wrote:
> On Tue, Apr 28, 2015 at 11:35 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > I am still not sure I see the problem here.
> 
> Basically, I absolutely hate the notion of us doing something
> unsynchronized, when I can see us undoing a mmap that another thread
> is doing. It's wrong.
> 
> You also didn't react to all the *other* things that were wrong in
> that patch-set. The games you play with !fatal_signal_pending() etc
> are just crazy.

I planed to get to those later, because I felt the locks vs. racing
mmaps argument was the most important objection.

> End result: I absolutely detest the whole thing. I told you what I
> consider an acceptable solution instead, that is much simpler and
> doesn't have any of the problems of your patchset.

I will surely think about those. As I've written in the cover email
already, I am fine with patching the man page and be clear about a long
term behavior. The primary motivation for this RFC was to start the
discussion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
