Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 304B76B00BC
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 10:25:09 -0500 (EST)
Subject: Re: [PATCH] Update of Documentation/ (VM sysctls)
From: "Peter W. Morreale" <pmorreale@novell.com>
In-Reply-To: <495D9222.1060306@oracle.com>
References: <20081231212615.12868.97088.stgit@hermosa.site>
	 <495D9222.1060306@oracle.com>
Content-Type: text/plain
Date: Fri, 02 Jan 2009 08:25:01 -0700
Message-Id: <1230909901.3470.242.camel@hermosa.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, comandante@zaralinux.com, bb@ricochet.net, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-01-01 at 20:03 -0800, Randy Dunlap wrote:
> Peter W Morreale wrote:

> > It assumes that patch: http://lkml.org/lkml/2008/12/31/219 has been applied.
> > This is probably wrong since that patch is still being reviewed and not
> > officially accepted as of this patch.  Not sure how to handle this at
> > all.  
> 
> Yes, this patch should be done first/regardless of your other (pending) patch.
> 

Wait a sec...  

There is a patch interdependency here.

This patch includes the text for the two proposed sysctls.  If they are
rejected, then this help text will refer to two non-existent sysctls.
Minor issue compared to:

The pdflush sysctl patch was respun to include adding text (against the
current vm.txt) for the new sysctls.  So that patch will fail to apply
should this patch be added first. 

See what I mean? So what do I do?

Thx,
-PWM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
