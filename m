Message-ID: <480F13F5.9090003@firstfloor.org>
Date: Wed, 23 Apr 2008 12:48:21 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 18/18] hugetlb: my fixes 2
References: <20080423015302.745723000@nick.local0.net> <20080423015431.569358000@nick.local0.net>
In-Reply-To: <20080423015431.569358000@nick.local0.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

npiggin@suse.de wrote:

Thanks for these fixes. The subject definitely needs improvement, or
rather all these fixes should be folded into the original patches.

> Here is my next set of fixes and changes:
> - Allow configurations without the default HPAGE_SIZE size (mainly useful
>   for testing but maybe it is the right way to go).

I don't think it is the correct way. If you want to do it this way you
would need to special case it in /proc/meminfo to keep things compatible.

Also in general I would think that always keeping the old huge page size
around is a good idea. There is some chance at least to allocate 2MB
pages after boot (especially with the new movable zone and with lumpy
reclaim), so it doesn't need to be configured at boot time strictly. And
why take that option away from the user?

Also I would hope that distributions keep their existing /hugetlbfs
(if they have one) at the compat size for 100% compatibility to existing
applications.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
