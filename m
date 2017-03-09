Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA9DD831FE
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:42:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 77so93432422pgc.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:42:27 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w7si5501274pgc.395.2017.03.08.22.42.26
        for <linux-mm@kvack.org>;
        Wed, 08 Mar 2017 22:42:27 -0800 (PST)
Date: Thu, 9 Mar 2017 15:42:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Do not use double negation for testing page flags
Message-ID: <20170309064224.GD854@bbox>
References: <1488868597-32222-1-git-send-email-minchan@kernel.org>
 <8b5c4679-484e-fe7f-844b-af5fd41b01e0@linux.vnet.ibm.com>
 <20170308052555.GB11206@bbox>
 <6f9274f7-6d2e-60a6-c36a-78f8f79004aa@suse.cz>
MIME-Version: 1.0
In-Reply-To: <6f9274f7-6d2e-60a6-c36a-78f8f79004aa@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <gang.chen.5i5j@gmail.com>

Hi Vlastimil,

On Wed, Mar 08, 2017 at 08:51:23AM +0100, Vlastimil Babka wrote:
> On 03/08/2017 06:25 AM, Minchan Kim wrote:
> > Hi Anshuman,
> > 
> > On Tue, Mar 07, 2017 at 09:31:18PM +0530, Anshuman Khandual wrote:
> >> On 03/07/2017 12:06 PM, Minchan Kim wrote:
> >>> With the discussion[1], I found it seems there are every PageFlags
> >>> functions return bool at this moment so we don't need double
> >>> negation any more.
> >>> Although it's not a problem to keep it, it makes future users
> >>> confused to use dobule negation for them, too.
> >>>
> >>> Remove such possibility.
> >>
> >> A quick search of '!!Page' in the source tree does not show any other
> >> place having this double negation. So I guess this is all which need
> >> to be fixed.
> > 
> > Yeb. That's the why my patch includes only khugepagd part but my
> > concern is PageFlags returns int type not boolean so user might
> > be confused easily and tempted to use dobule negation.
> > 
> > Other side is they who create new custom PageXXX(e.g., PageMovable)
> > should keep it in mind that they should return 0 or 1 although
> > fucntion prototype's return value is int type.
> 
> > It shouldn't be
> > documented nowhere.
> 
> Was this double negation intentional? :P

Nice catch!
It seems you have a crystal ball. ;-)

> 
> > Although we can add a little description
> > somewhere in page-flags.h, I believe changing to boolean is more
> > clear/not-error-prone so Chen's work is enough worth, I think.
> 
> Agree, unless some arches benefit from the int by performance
> for some reason (no idea if it's possible).
> 
> Anyway, to your original patch:
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
