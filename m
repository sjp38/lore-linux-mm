Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1096E6B0071
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 08:52:16 -0400 (EDT)
Date: Mon, 11 Oct 2010 07:52:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
In-Reply-To: <20101009095718.1775.qmail@kosh.dhis.org>
Message-ID: <alpine.DEB.2.00.1010110750390.6638@router.home>
References: <20101009095718.1775.qmail@kosh.dhis.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: pacman@kosh.dhis.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The contents of those scribbles may reveal something. Are these 4 bytes a
pointer? If so at what memory area are they pointing? A page struct?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
