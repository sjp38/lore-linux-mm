Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 87B9F6B006C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:01:45 -0500 (EST)
Date: Mon, 21 Nov 2011 05:01:37 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] readahead: make default readahead size a kernel
 parameter
Message-ID: <20111121100137.GC5084@infradead.org>
References: <20111121091819.394895091@intel.com>
 <20111121093846.251104145@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121093846.251104145@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ankit Jain <radical@gmail.com>, Dave Chinner <david@fromorbit.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon, Nov 21, 2011 at 05:18:21PM +0800, Wu Fengguang wrote:
> From: Nikanth Karthikesan <knikanth@suse.de>
> 
> Add new kernel parameter "readahead=", which allows user to override
> the static VM_MAX_READAHEAD=128kb.

Is a boot-time paramter really such a good idea?  I would at least make
it a sysctl so that it's run-time controllable, including beeing able
to set it from initscripts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
