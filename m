Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 21B49900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 12:27:26 -0400 (EDT)
Received: by qgfa63 with SMTP id a63so6098538qgf.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 09:27:25 -0700 (PDT)
Received: from pd.grulic.org.ar (pd.grulic.org.ar. [200.16.16.187])
        by mx.google.com with ESMTP id h65si1092316qkh.65.2015.06.03.09.27.24
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 09:27:25 -0700 (PDT)
Date: Wed, 3 Jun 2015 13:26:49 -0300
From: Marcos Dione <mdione@grulic.org.ar>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150603162649.GA15166@grulic.org.ar>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
 <20150312145422.GA9240@grulic.org.ar>
 <20150312153513.GA14537@dhcp22.suse.cz>
 <20150312165600.GC9240@grulic.org.ar>
 <20150313145851.GA26332@grulic.org.ar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150313145851.GA26332@grulic.org.ar>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Fri, Mar 13, 2015 at 11:58:51AM -0300, Marcos Dione wrote:
> On Thu, Mar 12, 2015 at 01:56:00PM -0300, Marcos Dione wrote:
> > On Thu, Mar 12, 2015 at 11:35:13AM -0400, Michal Hocko wrote:
> > > On Wed 11-03-15 19:10:44, Marcos Dione wrote:
> > > I also read Documentation/vm/overcommit-accounting
> > 
> > What would help you to understand it better?
> 
>     I think it's mostly a language barrier. The doc talks about of how
> the kernel handles the memory, but leaves userland people 'watching from
> outside the fence'. From the sysadmin and non-kernel developer (that not
> necesarily knows all the kinds of things that can be done with
> malloc/mmap/shem/&c) point of view, this is what I think the doc refers
> to:
> 
> > How It Works
> > ------------
> > 
> > The overcommit is based on the following rules
> > 
> > For a file backed map
> 
>     mmaps. are there more?

    answering myself: yes, code maps behave like this.

> >     SHARED or READ-only	-	0 cost (the file is the map not swap)
> >     PRIVATE WRITABLE	-	size of mapping per instance

    code is not writable, so only private writable mmaps are left. I
wonder why shared writable are accounted.

> > For an anonymous 
> 
>     malloc'ed memory
> 
> > or /dev/zero map
> 
>     hmmm, (read only?) mmap'ing on top of /dev/zero?
> 
> >     SHARED			-	size of mapping
> 
>     a shared anonymous memory is a shm?
> 
> >     PRIVATE READ-only	-	0 cost (but of little use)
> >     PRIVATE WRITABLE	-	size of mapping per instance
> 
>     I can't translate these two terms, unless the latter is the one
> refering specifically to mmalloc's. I wonder how could create several
> intances of the 'same' mapping in that case. forks?
> 
> > Additional accounting
> >     Pages made writable copies by mmap
> 
>     Hmmm, copy-on-write pages for when you write in a shared mmap? I'm
> wild guessing here, even when what I say doesn't make any sense.
> 
> >     shmfs memory drawn from the same pool
> 
>     Beats me.
[...]
>     Now it seems too simple! What I'm missing? :) Cheers,

    untrue, I'm still in the dark on what those mean. maybe someone can
translate those terms to userland terms? malloc, shm, mmap, code maps?
probably I'm missing some.

    cheers,

        -- Marcos.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
