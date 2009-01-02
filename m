Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D89AB6B00C7
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 13:19:01 -0500 (EST)
Subject: Re: [PATCH] Update of Documentation/
From: "Peter W. Morreale" <pmorreale@novell.com>
In-Reply-To: <495E585D.6090402@oracle.com>
References: <20090102180412.3676.27341.stgit@hermosa.site>
	 <495E585D.6090402@oracle.com>
Content-Type: text/plain
Date: Fri, 02 Jan 2009 11:18:55 -0700
Message-Id: <1230920335.3470.250.camel@hermosa.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, riel@nl.linux.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-02 at 10:09 -0800, Randy Dunlap wrote:
> Peter W Morreale wrote:
> > This patch updates Documentation/sysctl/vm.txt and
> > Documentation/filesystems/proc.txt.   More specifically, the section on
> > /proc/sys/vm in Documentation/filesystems/proc.txt was removed and a
> > link to Documentation/sysctl/vm.txt added.
> > 
> > Most of the verbiage from proc.txt was simply moved in vm.txt, with new
> > addtional text for "swappiness" and "stat_interval".
> > 
> > This update reflects the current state of 2.6.27.
> 
> Does it also reflect the current state of the most recently released
> mainline kernel (i.e., 2.6.28)?
> 
> More importantly, it does not apply cleanly to 2.6.28 or to today's
> linux-next-20090102 kernel.  It needs to do that, please.
> 

Ack, sorry.   Will respin.

-PWM



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
