Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A05D46B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:48:02 -0400 (EDT)
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2JFm0gT019567
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:48:00 -0400
Message-ID: <49C2692B.20006@redhat.com>
Date: Thu, 19 Mar 2009 11:47:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] mm tracepoints
References: <1237233134.1476.119.camel@dhcp-100-19-198.bos.redhat.com>
In-Reply-To: <1237233134.1476.119.camel@dhcp-100-19-198.bos.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Larry Woodman wrote:
> I've implemented several mm tracepoints to track page allocation and
> freeing, various types of pagefaults and unmaps, and critical page
> reclamation routines.  This is useful for debugging memory allocation
> issues and system performance problems under heavy memory loads.
> Thoughts?:

It looks mostly good.

I believe that the vmscan.c tracepoints could be a little
more verbose though, it would be useful to know whether we
are scanning anon or file pages and whether or not we're
doing lumpy reclaim.  Possibly the priority level, too.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
