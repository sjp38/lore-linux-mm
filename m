Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ABC5C6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:35:13 -0500 (EST)
Date: Fri, 13 Nov 2009 12:35:09 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Allow memory hotplug and hibernation in the same kernel
Message-ID: <20091113113509.GB30880@basil.fritz.box>
References: <20091113105944.GA16028@basil.fritz.box> <20091113200745.33CE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091113200745.33CE.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, gerald.schaefer@de.ibm.com, rjw@sisk.pl, linux-kernel@vger.kernel.org, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 08:13:23PM +0900, KOSAKI Motohiro wrote:
> (cc to goto-san)
> 
> > Allow memory hotplug and hibernation in the same kernel
> > 
> > Memory hotplug and hibernation was excluded in Kconfig. This is obviously
> > a problem for distribution kernels who want to support both in the same
> > image.
> 
> Sure.
> 
> This exclusion is nearly meaningless. if anybody remove cpu, memory and/or
> various peripheral from hibernated machine. the system might not resume.
> it's obvious. memory is not special.


The main motivation for the patch is really just to allow both in the 
same kernel (so the Kconfig change). The actual exclusion is 
not really very interesting as you point out.

Otherwise memory hotadd is not usable in universal kernel that
runs on laptops too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
