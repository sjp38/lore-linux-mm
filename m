Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4BBDD6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 04:51:59 -0400 (EDT)
Date: Fri, 8 May 2009 16:52:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 2/5] PM/Suspend: Do not shrink memory before
	suspend
Message-ID: <20090508085230.GA25924@localhost>
References: <200905070040.08561.rjw@sisk.pl> <200905072348.59856.rjw@sisk.pl> <200905072351.11639.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200905072351.11639.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 08, 2009 at 05:51:10AM +0800, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Remove the shrinking of memory from the suspend-to-RAM code, where
> it is not really necessary.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Acked-by: Nigel Cunningham <nigel@tuxonice.net>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
