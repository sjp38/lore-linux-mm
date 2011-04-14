Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F0A90900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:51:06 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3EJp4D5019871
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 12:51:04 -0700
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by wpaz37.hot.corp.google.com with ESMTP id p3EJp1KG006168
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 12:51:03 -0700
Received: by pvg4 with SMTP id 4so1051299pvg.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 12:51:01 -0700 (PDT)
Date: Thu, 14 Apr 2011 12:50:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
In-Reply-To: <20110414120920.1e6c04ff.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1104141250360.20747@chino.kir.corp.google.com>
References: <1300772711.26693.473.camel@localhost> <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com> <20110414144807.19ec5f69@notabene.brown> <20110414120920.1e6c04ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: NeilBrown <neilb@suse.de>, Ben Hutchings <ben@decadent.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, 14 Apr 2011, Andrew Morton wrote:

> From: Ben Hutchings <ben@decadent.org.uk>
> 
> The conventional format for boolean attributes in sysfs is numeric ("0" or
> "1" followed by new-line).  Any boolean attribute can then be read and
> written using a generic function.  Using the strings "yes [no]", "[yes]
> no" (read), "yes" and "no" (write) will frustrate this.
> 
> [akpm@linux-foundation.org: use kstrtoul()]
> [akpm@linux-foundation.org: test_bit() doesn't return 1/0, per Neil]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Johannes Weiner <jweiner@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: NeilBrown <neilb@suse.de>
> Cc: <stable@kernel.org> 	[2.6.38.x]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Tested-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
