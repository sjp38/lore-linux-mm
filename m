Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A680A6B003D
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 20:45:23 -0500 (EST)
Date: Thu, 3 Dec 2009 09:45:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/24] HWPOISON: make it possible to unpoison pages
Message-ID: <20091203014518.GB8520@localhost>
References: <20091202031231.735876003@intel.com> <20091202043045.150526892@intel.com> <20091202131530.GG18989@one.firstfloor.org> <20091202134645.GA19274@localhost> <20091202140305.GL18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202140305.GL18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 10:03:05PM +0800, Andi Kleen wrote:
> > btw, do you feel comfortable with the interface name "renew-pfn"?
> > (versus "unpoison-pfn")
> 
> I prefer unpoison, that makes it clear what it is.

OK.

> Maybe even call it "software_unpoison_pfn", because it won't unpoison on the 
> hardware level (this really should be documented somewhere too)

Yes we can document it in Documentation/vm/hwpoison.txt.

Does that mean we may introduce a "hardware_unpoison_pfn" in future?
(a superset of software_unpoison_pfn)

And "software_unpoison_pfn" may make the other "corrupt-pfn" a bit
confusing ;)


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
