From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16997.3467.378280.467539@gargle.gargle.HOWL>
Date: Tue, 19 Apr 2005 17:54:19 +0400
Subject: Re: [PATCH]: VM 4/8 dont-rotate-active-list
In-Reply-To: <Pine.LNX.4.61.0504180847350.3232@chimarrao.boston.redhat.com>
References: <16994.40620.892220.121182@gargle.gargle.HOWL>
	<Pine.LNX.4.61.0504180847350.3232@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Rik van Riel writes:
 > On Sun, 17 Apr 2005, Nikita Danilov wrote:
 > 
 > > This patch modifies refill_inactive_zone() so that it scans active_list
 > > without rotating it. To achieve this, special dummy page zone->scan_page
 > > is maintained for each zone. This page marks a place in the active_list
 > > reached during scanning.
 > 
 > Doesn't this make the active list behave closer to FIFO ?
 > 
 > How does this behave when running a mix of multiple
 > applications, instead of one app that's referencing
 > memory in a circular pattern ?   Say, AIM7 ?

Nick Piggin found that this patch improves kbuild performance:

http://mail.nl.linux.org/linux-mm/2004-01/msg00111.html

That thread also contains lengthy discussion of why this patch was
supposed to work.

 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
