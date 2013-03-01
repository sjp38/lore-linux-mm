Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 810F96B0002
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 05:23:57 -0500 (EST)
Date: Fri, 1 Mar 2013 11:23:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: +
 mm-show_mem-suppress-page-counts-in-non-blockable-contexts.patch added to
 -mm tree
Message-ID: <20130301102355.GC21443@dhcp22.suse.cz>
References: <20130228231025.9F11A5A410E@corp2gmr1-2.hot.corp.google.com>
 <20130301095716.GA21443@dhcp22.suse.cz>
 <alpine.DEB.2.02.1303010213140.23298@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303010213140.23298@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, dave@linux.vnet.ibm.com, mgorman@suse.de, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 01-03-13 02:15:04, David Rientjes wrote:
> On Fri, 1 Mar 2013, Michal Hocko wrote:
> 
> > I have already asked about it in the original thread but didn't get any
> > answer. How can we get a soft lockup when all implementations of show_mem
> > call touch_nmi_watchdog?
> > 
> 
> Feel free to do s/soft lockups/irqs being disabled for an extremely long 
> time/.

OK, that sounds better. Sorry for being so persistent on this but soft
lockups tend to be a real issue for distribution kernels with
!CONFIG_PREEMPT so anything that fixes soft lockups raises a red flag.

Acked-by: Michal Hocko <mhocko@suse.cz>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
