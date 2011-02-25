Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87A8D8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 20:36:12 -0500 (EST)
Date: Fri, 25 Feb 2011 02:36:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110225013608.GL5818@one.firstfloor.org>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org> <1298425922-23630-9-git-send-email-andi@firstfloor.org> <1298587384.9138.23.camel@nimitz> <20110224231449.GE23252@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110224231449.GE23252@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

> I've a micropreference in having it in split_huge_page succeeding path
> after __split_huge_page returns, as the __ function is where the
> brainer code is and statcode to me is annoying to read mixed in the
> more complex code. Not that it makes any practical difference though.

Thanks for the improvements.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
