Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 133856B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 11:24:48 -0500 (EST)
Message-ID: <4B86A445.5000807@redhat.com>
Date: Thu, 25 Feb 2010 11:24:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/15] readahead: thrashing safe context readahead
References: <20100224031001.026464755@intel.com> <20100224031054.588144188@intel.com>
In-Reply-To: <20100224031054.588144188@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Introduce a more complete version of context readahead, which is a
> full-fledged readahead algorithm by itself. It replaces some of the
> existing cases.

> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
