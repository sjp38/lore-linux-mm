Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86
	(bisected)
From: Dan Williams <dan.j.williams@intel.com>
In-Reply-To: <20080701190741.GB16501@csn.ul.ie>
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com>
	 <20080701080910.GA10865@csn.ul.ie> <20080701175855.GI32727@shadowen.org>
	 <20080701190741.GB16501@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 01 Jul 2008 15:28:32 -0700
Message-Id: <1214951312.26855.26.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, cl@linux-foundation.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-01 at 12:07 -0700, Mel Gorman wrote:
> This looks kinda promising and depends heavily on how this patch was
> tested in isolation. Dan, can you post the patch you use on 2.6.25
> because the commit in question should not have applied cleanly please?

?

I have not tested this patch (54a6eb5c) in isolation.  The patch that
was applied to 2.6.25 was the raid5 performance enhancement patch.  It
is no longer in the equation since the problem is reproducible with
stock raid0.

--
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
