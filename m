Date: Tue, 25 Apr 2006 01:37:12 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page host virtual assist patches.
Message-Id: <20060425013712.365892c2.akpm@osdl.org>
In-Reply-To: <1145953914.5282.21.camel@localhost>
References: <20060424123412.GA15817@skybase>
	<20060424180138.52e54e5c.akpm@osdl.org>
	<444DCD87.2030307@yahoo.com.au>
	<1145953914.5282.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> > Definitely. The current patches seem like just an extra layer to do
>  > everything we can already -- reclaim unused pages and populate them
>  > again when they get touched.
>  > 
>  > And complex they are. Having the core VM have to know about all this
>  > weird stuff seems... not good.
> 
>  The point here is WHO does the reclaim. Sure we can do the reclaim in
>  the guest but it is the host that has the memory pressure. To call into
>  the guest is not a good idea, if you have an idle guest you generally
>  increase the memory pressure because some of the guests pages might have
>  been swapped which are needed if the guest has to do the reclaim. 

Cannot the guests employ text sharing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
