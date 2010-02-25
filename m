Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 215836B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 09:59:23 -0500 (EST)
Message-ID: <4B869034.8010305@redhat.com>
Date: Thu, 25 Feb 2010 09:59:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/15] readahead: make default readahead size a kernel
 parameter
References: <20100224031001.026464755@intel.com> <20100224031054.161214875@intel.com>
In-Reply-To: <20100224031054.161214875@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Ankit Jain <radical@gmail.com>, Dave Chinner <david@fromorbit.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Nikanth Karthikesan <knikanth@suse.de>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> From: Nikanth Karthikesan<knikanth@suse.de>
>
> Add new kernel parameter "readahead", which allows user to override
> the static VM_MAX_READAHEAD=512kb.
>
> CC: Ankit Jain<radical@gmail.com>
> CC: Dave Chinner<david@fromorbit.com>
> CC: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
> Signed-off-by: Nikanth Karthikesan<knikanth@suse.de>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
