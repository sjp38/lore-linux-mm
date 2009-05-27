Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F08256B00A6
	for <linux-mm@kvack.org>; Wed, 27 May 2009 16:36:28 -0400 (EDT)
Date: Wed, 27 May 2009 13:35:11 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [PATCH] [1/16] HWPOISON: Add page flag for poisoned pages
Message-ID: <20090527203511.GA26530@oblivion.subreption.com>
References: <200905271012.668777061@firstfloor.org> <20090527201226.CCCBB1D028F@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090527201226.CCCBB1D028F@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On 22:12 Wed 27 May     , Andi Kleen wrote:
> 
> Hardware poisoned pages need special handling in the VM and shouldn't be 
> touched again. This requires a new page flag. Define it here.
> 
> The page flags wars seem to be over, so it shouldn't be a problem
> to get a new one.

I gave a look to your patchset and this is yet another case in which the
only way to truly control the allocation/release behavior at low level
(without intrusive approaches) is to -indeed- use a page flag.

If this gets merged I would like to ask Andrew and Christopher to look
at my recent memory sanitization patches. It seems the opinion about
adding new page flags isn't the same for everyone here.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
