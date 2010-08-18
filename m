Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1692F6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:45:12 -0400 (EDT)
Date: Wed, 18 Aug 2010 23:45:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/page-writeback: fix non-kernel-doc function comments
Message-ID: <20100818154502.GD9431@localhost>
References: <20100814130517.daf2ebf4.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100814130517.daf2ebf4.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, torvalds <torvalds@linux-foundation.org>, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 14, 2010 at 01:05:17PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Remove leading /** from non-kernel-doc function comments to prevent
> kernel-doc warnings.

Thanks for the catch!

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
