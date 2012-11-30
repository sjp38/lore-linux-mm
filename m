Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9A0946B0044
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 20:32:13 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id l8so99820qaq.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 17:32:12 -0800 (PST)
Date: Thu, 29 Nov 2012 17:32:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: O_DIRECT on tmpfs (again)
In-Reply-To: <x498v9kwhzy.fsf@segfault.boston.devel.redhat.com>
Message-ID: <alpine.LNX.2.00.1211291659260.3510@eggly.anvils>
References: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com> <alpine.LNX.2.00.1211281248270.14968@eggly.anvils> <50B6830A.20308@oracle.com> <x498v9kwhzy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 29 Nov 2012, Jeff Moyer wrote:
> Dave Kleikamp <dave.kleikamp@oracle.com> writes:
> 
> >> Whilst I agree with every contradictory word I said back then ;)
> >> my current position is to wait to see what happens with Shaggy's "loop:
> >> Issue O_DIRECT aio using bio_vec" https://lkml.org/lkml/2012/11/22/847
> >
> > As the patches exist today, the loop driver will only make the aio calls
> > if the underlying file defines a direct_IO address op since
> > generic_file_read/write_iter() will call a_ops->direct_IO() when
> > O_DIRECT is set. For tmpfs or any other filesystem that doesn't support
> > O_DIRECT, the loop driver will continue to call the read() or write()
> > method.
> 
> Hi, Hugh and Shaggy,
> 
> Thanks for your replies--it looks like we're back to square one.  I
> think it would be trivial to add O_DIRECT support to tmpfs, but I'm not
> convinced it's necessary.  Should we wait until bug reports start to
> come in?

It's reassuring to know that tmpfs won't have to rush in direct_IO
to support loop when Dave's changes go through (thanks); but I'd still
like to experiment with going that way, to see if it works better.

I've not been entirely convinced that tmpfs needs direct_IO either;
but your links from back then show a number of people who feel that
direct_IO had become mainstream enough to deserve the appearance of
support by tmpfs.

And you observe that tmpfs is being used more widely for /tmp nowadays:
I agree that may increase its desirability.

Like you, I'm really hoping someone will join in and say they'd been
disadvantaged by lack of O_DIRECT on tmpfs: no strong feeling myself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
