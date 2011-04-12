Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8920D900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 13:11:54 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3CGtn11018852
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:55:49 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3CHBmLO048510
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:11:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3CHBlQQ012077
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:11:48 -0600
Subject: Re: [PATCH 1/3] rename alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <87r597jt45.fsf@gmail.com>
References: <20110411220345.9B95067C@kernel>  <87r597jt45.fsf@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 12 Apr 2011 10:11:45 -0700
Message-ID: <1302628305.8321.2274.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

On Wed, 2011-04-13 at 02:07 +0900, Namhyung Kim wrote:
> >                       if (get_order(size) < MAX_ORDER) {
> > -                             table = alloc_pages_exact(size, GFP_ATOMIC);
> > +                             table = get_free_pages_exact(size, GFP_ATOMIC);
> 
> This should be                  table = get_free_pages_exact(GFP_ATOMIC, size);

It's clear that I'm retarded and need to learn how to use sparse.  :)

Thanks!

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
