Date: Fri, 15 Jun 2007 15:11:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [3/6] walk memory resources assist
 function.
Message-Id: <20070615151132.a6ffa1e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.0.99.0706142304530.1729@chino.kir.corp.google.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614160156.9aa218ec.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.99.0706142304530.1729@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 23:05:22 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > +		len = (unsigned long)(res.end + 1 - res.start) >> PAGE_SHIFT;
> 
> This needs to be
> 
> 	len = (unsigned long)((res.end + 1 - res.start) >> PAGE_SHIFT);
> 
Okay, thank you for review. will fix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
