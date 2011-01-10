Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E5E26B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 14:11:24 -0500 (EST)
Date: Mon, 10 Jan 2011 13:11:22 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0/4] De-couple sysfs memory directories from memory
 sections
Message-ID: <20110110191122.GN2912@sgi.com>
References: <4D2B4B38.80102@austin.ibm.com>
 <20110110184416.GA18974@kroah.com>
 <4D2B543A.3070609@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D2B543A.3070609@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

> >> The root of this issue is in sysfs directory creation. Every time
> >> a directory is created a string compare is done against all sibling
> >> directories to ensure we do not create duplicates.  The list of
> >> directory nodes in sysfs is kept as an unsorted list which results
> >> in this being an exponentially longer operation as the number of
> >> directories are created.
> > 
> > Are you sure this is still an issue?  I thought we solved this last
> > kernel or so with a simple patch?
> 
> I'll go back and look at this again.

What I recall fixing is the symbolic linking from the node* to the
memory section.  In that case, we cached the most recent mem section
and since they always were added sequentially, the cache saved a rescan.

Of course, I could be remembering something completely unrelated.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
