Date: Tue, 6 Mar 2001 17:56:10 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Linux 2.2 vs 2.4 for PostgreSQL
In-Reply-To: <Pine.LNX.4.10.10103061626070.20708-100000@sphinx.mythic-beasts.com>
Message-ID: <Pine.LNX.4.21.0103061742500.852-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Kirkwood <matthew@hairy.beasts.org>
Cc: linux-mm@kvack.org, Mike Galbraith <mikeg@wen-online.de>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2001, Matthew Kirkwood wrote:

> Hi,
> 
> I have been collecting some postgres benchmark numbers
> on various kernels, which may be of interest to this
> list.
> 
> The test was to run "pgbench" with various numbers of
> clients against postgresql 7.1beta4.  The benchmark
> looks rather like a fairly minimal TPC/B, with lots of
> small transactions, all committed.  It's not very
> complex, but does produce pretty stable numbers, and
> appears capable of showing up performance improvements
> or deteriorations.

Very nice.

<snip>

> Invitations:
>  * Anyone care to suggest any patches/configuration tweaks/
>    &c, which might prove an interesting test?  Are there
>    significant elevator/VM differences between 2.4.2ac and
>    2.4.3pre?

Yes, there are significant VM differenteces between Linus tree and -ac.

I'll try to setup the environment for this benchmark today on one of our
(working) test boxes. 

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
