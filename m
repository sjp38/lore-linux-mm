Date: Fri, 15 Jun 2007 15:12:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [5/6] page unplug
Message-Id: <20070615151242.9226b64b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.0.99.0706142303460.1729@chino.kir.corp.google.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.99.0706142303460.1729@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 23:04:50 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > +		page = pfn_to_page(pfn);
> > +#endif
> 
> Please extract this out to inlined functions that are conditional are 
> CONFIG_HOLES_IN_ZONE.
> 
Hmm. ok, I"ll do.

thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
