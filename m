Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 410506B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:51:28 -0400 (EDT)
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2JFpPSV020364
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:51:25 -0400
Subject: Re: [Patch] mm tracepoints
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <49C2692B.20006@redhat.com>
References: <1237233134.1476.119.camel@dhcp-100-19-198.bos.redhat.com>
	 <49C2692B.20006@redhat.com>
Content-Type: text/plain
Date: Thu, 19 Mar 2009 11:55:29 -0400
Message-Id: <1237478129.1476.125.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-19 at 11:47 -0400, Rik van Riel wrote:
> Larry Woodman wrote:
> > I've implemented several mm tracepoints to track page allocation and
> > freeing, various types of pagefaults and unmaps, and critical page
> > reclamation routines.  This is useful for debugging memory allocation
> > issues and system performance problems under heavy memory loads.
> > Thoughts?:
> 
> It looks mostly good.
> 
> I believe that the vmscan.c tracepoints could be a little
> more verbose though, it would be useful to know whether we
> are scanning anon or file pages and whether or not we're
> doing lumpy reclaim.  Possibly the priority level, too.
> 

OK thanks, I'll address these concerns.

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
