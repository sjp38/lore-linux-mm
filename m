Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DD7BC6B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:44:29 -0400 (EDT)
Date: Thu, 12 May 2011 09:44:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: Add statistics for this_cmpxchg_double failures
In-Reply-To: <alpine.DEB.2.00.1105111349350.9346@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1105120943570.24560@router.home>
References: <alpine.DEB.2.00.1103221333130.16870@router.home> <alpine.DEB.2.00.1105111349350.9346@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Wed, 11 May 2011, David Rientjes wrote:

> I see this has been merged as 4fdccdfbb465, but it seems pretty pointless
> unless you export the data to userspace with the necessary STAT_ATTR() and
> addition in slab_attrs.

Right that slipped into a later patch that only dealt with statistics. But
I will fold that into the earlier patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
