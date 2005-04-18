Date: Mon, 18 Apr 2005 08:49:12 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH]: VM 4/8 dont-rotate-active-list
In-Reply-To: <16994.40620.892220.121182@gargle.gargle.HOWL>
Message-ID: <Pine.LNX.4.61.0504180847350.3232@chimarrao.boston.redhat.com>
References: <16994.40620.892220.121182@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org, Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

On Sun, 17 Apr 2005, Nikita Danilov wrote:

> This patch modifies refill_inactive_zone() so that it scans active_list
> without rotating it. To achieve this, special dummy page zone->scan_page
> is maintained for each zone. This page marks a place in the active_list
> reached during scanning.

Doesn't this make the active list behave closer to FIFO ?

How does this behave when running a mix of multiple
applications, instead of one app that's referencing
memory in a circular pattern ?   Say, AIM7 ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
