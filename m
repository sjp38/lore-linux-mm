Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C52068D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 18:42:44 -0400 (EDT)
Message-ID: <4DA383D3.100@freescale.com>
Date: Mon, 11 Apr 2011 17:42:27 -0500
From: Timur Tabi <timur@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
References: <20110411220345.9B95067C@kernel>	 <20110411220346.2FED5787@kernel>	 <20110411152223.3fb91a62.akpm@linux-foundation.org> <1302561360.7286.16848.camel@nimitz>
In-Reply-To: <1302561360.7286.16848.camel@nimitz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

Dave Hansen wrote:
>> > Hand-optimised.  Old school.  Doesn't trust the compiler :)

> Hey, ask the dude who put free_pages_exact() in there! :)

Ugh, I don't remember at all why I wrote it the way I did.  I'm pretty sure I
copied the style from somewhere else, since these functions are not really my
area of expertise.

When you guys finally agree on the order of the parameters :) I'll test out the
functions on my board.

-- 
Timur Tabi
Linux kernel developer at Freescale

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
