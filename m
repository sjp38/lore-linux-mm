Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 22F165F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:53:03 -0400 (EDT)
Date: Tue, 7 Apr 2009 23:56:05 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [5/16] POISON: Add support for poison swap entries
Message-ID: <20090407215605.GZ17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151002.0AA8F1D046E@basil.firstfloor.org> <alpine.DEB.1.10.0904071710500.12192@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904071710500.12192@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 05:11:26PM -0400, Christoph Lameter wrote:
> 
> Could you separate the semantic changes to flag checking for migration

You mean to try_to_unmap? 

> out for easier review?

That's already done. The first patch doesn't change any semantics,
just flags/action checking.  Or rather any semantics change in there
would be a bug.

Only the two later ttu patches add to the semantics.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
