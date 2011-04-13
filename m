Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94F91900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:28:49 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3DJSkgG021512
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:28:46 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by wpaz17.hot.corp.google.com with ESMTP id p3DJSiHG028634
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:28:44 -0700
Received: by pwi3 with SMTP id 3so651544pwi.37
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:28:43 -0700 (PDT)
Date: Wed, 13 Apr 2011 12:28:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
In-Reply-To: <20110413121925.55493041.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1104131224430.7052@chino.kir.corp.google.com>
References: <1300772711.26693.473.camel@localhost> <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com> <20110413121925.55493041.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ben Hutchings <ben@decadent.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 13 Apr 2011, Andrew Morton wrote:

> It's a bit naughty to change the existing interface in 2.6.38.x but the time
> window is small and few people will be affected and they were nuts to be
> using 2.6.38.0 anyway ;)
> 
> I suppose we could support both the old and new formats for a while,
> then retire the old format but I doubt if it's worth it.
> 
> Isn't there some user documentation which needs to be updated to
> reflect this change?  If not, why not?  :)
> 

Indeed there is, in Documentation/vm/transhuge.txt -- only for 
/sys/kernel/mm/transparent_hugepage/khugepaged/defrag, though, we lack 
documentation of debug_cow.

Ben, do you have time to update the patch?  It sounds like this is 2.6.39 
material.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
