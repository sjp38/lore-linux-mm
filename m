Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 544BF6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 20:15:56 -0500 (EST)
Received: by wmec201 with SMTP id c201so1958819wme.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:15:56 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id m135si712329wmb.47.2015.11.19.17.15.55
        for <linux-mm@kvack.org>;
        Thu, 19 Nov 2015 17:15:55 -0800 (PST)
Date: Fri, 20 Nov 2015 02:03:11 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
Message-ID: <20151120010311.GA31728@1wt.eu>
References: <20151120001043.GA28204@www.outflux.net> <20151120010016.GB31694@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151120010016.GB31694@1wt.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, linux-mm@kvack.org

On Fri, Nov 20, 2015 at 02:00:16AM +0100, Willy Tarreau wrote:
> > diff --git a/mm/memory.c b/mm/memory.c
> > index deb679c31f2a..4c970a4e0057 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
> >  
> >  		if (!page_mkwrite)
> >  			file_update_time(vma->vm_file);
> > +		file_remove_privs(vma->vm_file);
> 
> I thought you said in one of the early mails of this thread that it
> didn't work. Or maybe I misunderstood.

OK never mind for this one I just saw the other mail where you said
the test is OK now. But I'm still worried about the performance so
the other point below remains :

> Also, don't you think we should move that into the if (!page_mkwrite)
> just like for the time update ?

Thanks!
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
