Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5FEnvgt027200
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 10:49:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5FFqmGw344142
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 11:52:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5FFqmOJ004922
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 11:52:48 -0400
Subject: Re: [RFC] memory unplug v5 [5/6] page unplug
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 15 Jun 2007 08:52:41 -0700
Message-Id: <1181922762.28189.30.camel@spirit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-14 at 16:04 +0900, KAMEZAWA Hiroyuki wrote:
> 
> +       if (start_pfn & (pageblock_nr_pages - 1))
> +               return -EINVAL;
> +       if (end_pfn & (pageblock_nr_pages - 1))
> +               return -EINVAL; 

After reading these, I'm still not sure I know what a pageblock is
supposed to be. :)  Did those come from Mel's patches?

In any case, I think it might be helpful to wrap up some of those
references in functions.  I was always looking at the patches trying to
find if "pageblock_nr_pages" was a local variable or not.  A function
would surely tell me.

static inline int pfn_is_pageblock_aligned(unsigned long pfn)
{
	return pfn & (pageblock_nr_pages - 1)
}

and, then you get

		BUG_ON(!pfn_is_pageblock_aligned(start_pfn));

It's pretty obvious what is going on, there. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
