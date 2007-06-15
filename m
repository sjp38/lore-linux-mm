Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5FLAohg007456
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 17:10:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5FL9fHV128820
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 17:09:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5FL9e9v017987
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 17:09:41 -0400
Subject: Re: [RFC] memory unplug v5 [5/6] page unplug
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070616020348.b4f2aab5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
	 <1181922762.28189.30.camel@spirit>
	 <20070616020348.b4f2aab5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 15 Jun 2007 14:09:39 -0700
Message-Id: <1181941779.28189.36.camel@spirit.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Sat, 2007-06-16 at 02:03 +0900, KAMEZAWA Hiroyuki wrote:
> 
> Hmm...I'll try that in the next version. But Is there some macro
> to do this ? like..
> --
> #define IS_ALIGNED(val, align)  ((val) & (align - 1)) 

Yep, that's a bit better.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
