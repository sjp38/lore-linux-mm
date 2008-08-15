Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7FGL0a0011184
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 12:21:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7FGL0sr175998
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 10:21:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7FGKxvY023048
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 10:20:59 -0600
Subject: Re: sparsemem support for mips with highmem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48A5AADE.1050808@sciatl.com>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz>
	 <48A4C542.5000308@sciatl.com>  <20080815080331.GA6689@alpha.franken.de>
	 <1218815299.23641.80.camel@nimitz>  <48A5AADE.1050808@sciatl.com>
Content-Type: text/plain
Date: Fri, 15 Aug 2008 09:20:57 -0700
Message-Id: <1218817257.23641.90.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-15 at 09:12 -0700, C Michael Sundius wrote:
> One thing that I had thought about and also came up when my peers here
> reviewed my changes was that we probably could put those bit numbers
> (at the very least the segment size) in the .config file.
> 
> we decided that the power that be might have had a reason for that and
> we left it not wanting to meddle with the other arch's.
> 
> Dave, do you have a comment about that?

Doing it with Kconfig would be fine with me.  It would be an excellent
place to add that help text.  Although, I'm not sure that it should be
something that is interactive.  Probably just strictly take the place of
the #defines we already have.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
