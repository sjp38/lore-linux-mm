Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id B490F6B0002
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 05:15:06 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ro8so1665032pbb.18
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 02:15:06 -0800 (PST)
Date: Fri, 1 Mar 2013 02:15:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: + mm-show_mem-suppress-page-counts-in-non-blockable-contexts.patch
 added to -mm tree
In-Reply-To: <20130301095716.GA21443@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1303010213140.23298@chino.kir.corp.google.com>
References: <20130228231025.9F11A5A410E@corp2gmr1-2.hot.corp.google.com> <20130301095716.GA21443@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, dave@linux.vnet.ibm.com, mgorman@suse.de, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 1 Mar 2013, Michal Hocko wrote:

> I have already asked about it in the original thread but didn't get any
> answer. How can we get a soft lockup when all implementations of show_mem
> call touch_nmi_watchdog?
> 

Feel free to do s/soft lockups/irqs being disabled for an extremely long 
time/.

> I do agree with the change but the above justification seems misleading.
> Can we just remove the information because it is costly and doesn't give
> us anything relevant to debug allocation failures?
> 

I believe I have already said yes, that all pertinent information is 
already there and I do not believe this additional information 
continuously spewed to the kernel log is helpful in debugging VM issues or 
understanding why the oom condition exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
