Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C65FA6B004F
	for <linux-mm@kvack.org>; Fri, 29 May 2009 12:36:52 -0400 (EDT)
Message-ID: <4A200F40.9050703@redhat.com>
Date: Fri, 29 May 2009 12:37:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [2/16] HWPOISON: Export poison flag in /proc/kpageflags
References: <200905271012.668777061@firstfloor.org> <20090527201227.EAEC41D0286@basil.firstfloor.org>
In-Reply-To: <20090527201227.EAEC41D0286@basil.firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> From: Fengguang Wu <fengguang.wu@intel.com>
> 
> Export the new poison flag in /proc/kpageflags. Poisoned pages are moderately
> interesting even for administrators, so export them here. Also useful
> for debugging.
> 
> AK: I extracted this out of a larger patch from Fengguang Wu.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

OK, this could be a good reason for the use of the PG_poisoned page
flag in patch 1/16.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
