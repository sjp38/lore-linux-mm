Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 773096B0047
	for <linux-mm@kvack.org>; Fri,  8 May 2009 04:53:00 -0400 (EDT)
Date: Fri, 8 May 2009 16:53:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 3/5] PM/Hibernate: Move memory shrinking to
	snapshot.c (rev. 2)
Message-ID: <20090508085316.GB25924@localhost>
References: <200905070040.08561.rjw@sisk.pl> <200905072348.59856.rjw@sisk.pl> <200905072351.57381.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200905072351.57381.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 08, 2009 at 05:51:56AM +0800, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The next patch is going to modify the memory shrinking code so that
> it will make memory allocations to free memory instead of using an
> artificial memory shrinking mechanism for that.  For this purpose it
> is convenient to move swsusp_shrink_memory() from
> kernel/power/swsusp.c to kernel/power/snapshot.c, because the new
> memory-shrinking code is going to use things that are local to
> kernel/power/snapshot.c .
> 
> [rev. 2: Make some functions static and remove their headers from
>  kernel/power/power.h]
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Acked-by: Pavel Machek <pavel@ucw.cz>

Acked-by: Wu Fengguang <fengguang.wu@intel.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
