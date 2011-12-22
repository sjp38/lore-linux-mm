Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6B9696B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 12:31:37 -0500 (EST)
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 7654E207C7
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 12:31:36 -0500 (EST)
Date: Thu, 22 Dec 2011 09:31:29 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging
 foundation
Message-ID: <20111222173129.GB28856@kroah.com>
References: <20111222155050.GA21405@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111222155050.GA21405@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, kurt.hackel@oracle.com, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com

On Thu, Dec 22, 2011 at 07:50:50AM -0800, Dan Magenheimer wrote:
> >From 93c00028709a5d423de77a2fc24d32ec10eca443 Mon Sep 17 00:00:00 2001
> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Date: Wed, 21 Dec 2011 14:01:54 -0700
> Subject: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging foundation

Why duplicate this in the email body?  That forces me to edit the
patches and remove them, please use git send-email...

> Copy cluster subdirectory from ocfs2.  These files implement
> the basic cluster discovery, mapping, heartbeat / keepalive, and
> messaging ("o2net") that ramster requires for internode communication.
> Note: there are NO ramster-specific changes yet; this commit
> does NOT pass checkpatch since the copied source files do not.

Why are you copying the files, and not just exporting the symbols you
need/want to use here?  Are you going to be able to properly track
keeping this code in sync?

Same goes for your other patch in this series that copies code, why do
that?  Are there goals to eventually not have duplicated code?  If so,
what are they, and why not mention them?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
