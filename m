Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 6BEC16B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:12:29 -0500 (EST)
Date: Tue, 27 Nov 2012 16:12:06 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/1] mm: Export a function to get vm committed memory
Message-ID: <20121127211206.GA10391@phenom.dumpdata.com>
References: <1352818957-9229-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211131307090.5164@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211131307090.5164@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com, dan.magenheimer@oracle.com

On Tue, Nov 13, 2012 at 01:07:30PM -0800, David Rientjes wrote:
> On Tue, 13 Nov 2012, K. Y. Srinivasan wrote:
> 
> > It will be useful to be able to access global memory commitment from device
> > drivers. On the Hyper-V platform, the host has a policy engine to balance
> > the available physical memory amongst all competing virtual machines
> > hosted on a given node. This policy engine is driven by a number of metrics
> > including the memory commitment reported by the guests. The balloon driver
> > for Linux on Hyper-V will use this function to retrieve guest memory commitment.
> > This function is also used in Xen self ballooning code.
> > 
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

I am bit late to this party - and back from vacation - so not sure if this
is merged in or not. Either way:

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> on the drivers/xen* side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
