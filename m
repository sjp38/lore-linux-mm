Date: Mon, 13 Sep 2004 20:10:46 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-ID: <20040913231046.GB23588@logos.cnet>
References: <20040913215753.GA23119@logos.cnet> <20040913164510.249eb7b1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040913164510.249eb7b1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, mbligh@aracnet.com, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2004 at 04:45:10PM -0700, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > The truncate VM functions use pagevec's for operation batching, but they mark
> >  the pagevec used to hold being-truncated-pages as "cache hot". 
> > 
> >  There is nothing which indicates such pages are likely to be "cache hot" - the
> >  following patch marks being-truncated-pages as cold instead. 
> 
> Disagree.
> 
> 	blah > /tmp/foo
> 	rm /tmp/foo

Well thats sys_unlink(). It does truncate?

Anyway, I think thats not the common case at all. 
Hum, it depends on the workload, but still.

But yeah, you have a point. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
