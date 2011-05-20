Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D5F796B0027
	for <linux-mm@kvack.org>; Fri, 20 May 2011 10:32:05 -0400 (EDT)
Date: Fri, 20 May 2011 09:32:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] kernel buffer overflow kmalloc_slab() fix
In-Reply-To: <1305843552.2400.36.camel@localhost>
Message-ID: <alpine.DEB.2.00.1105200931400.5610@router.home>
References: <james_p_freyensee@linux.intel.com>  <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>  <alpine.DEB.2.00.1105191550001.12530@router.home>  <1305839647.2400.32.camel@localhost>  <alpine.DEB.2.00.1105191618460.12530@router.home>
 <1305843552.2400.36.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <james_p_freyensee@linux.intel.com>
Cc: linux-mm@kvack.org, gregkh@suse.de, hari.k.kanigeri@intel.com

On Thu, 19 May 2011, J Freyensee wrote:

> > Not sure what to do instead of returning -1 in kmalloc_slab.
>
> I think returning -1 is fine; I just think code using the function
> should be checking for it and protect itself for errors in kernel space.

The function never returns -1 as I explained before.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
