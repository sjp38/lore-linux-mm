Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id DD9456B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 17:33:42 -0500 (EST)
Date: Tue, 19 Feb 2013 22:33:32 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/2] mm: Allow arch code to control the user page table
 ceiling
Message-ID: <20130219223330.GA6889@MacBook-Pro.local>
References: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
 <1361204311-14127-2-git-send-email-catalin.marinas@arm.com>
 <alpine.LNX.2.00.1302191005320.2139@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302191005320.2139@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Tue, Feb 19, 2013 at 06:08:12PM +0000, Hugh Dickins wrote:
> On Mon, 18 Feb 2013, Catalin Marinas wrote:
> 
> > From: Hugh Dickins <hughd@google.com>
> 
> You're being generous to me :)

OTOH, there are better chances to get the patch upstream ;)

> Thanks for doing most of the work, yes, this looks fine.
> BUt I'd have expected a Cc stable below: see comment on 2/2.

Yes, I will add cc stable. When I post patches for review I usually
avoid cc'ing stable since Git has the habit of actually sending the
email to stable@vger.kernel.org (and I want it to email the other people
on cc).

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
