Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDA56B0390
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 00:25:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 77so38955614pgc.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 21:25:58 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p1si2138391pld.214.2017.03.07.21.25.56
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 21:25:57 -0800 (PST)
Date: Wed, 8 Mar 2017 14:25:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Do not use double negation for testing page flags
Message-ID: <20170308052555.GB11206@bbox>
References: <1488868597-32222-1-git-send-email-minchan@kernel.org>
 <8b5c4679-484e-fe7f-844b-af5fd41b01e0@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b5c4679-484e-fe7f-844b-af5fd41b01e0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Vlastimil Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <gang.chen.5i5j@gmail.com>

Hi Anshuman,

On Tue, Mar 07, 2017 at 09:31:18PM +0530, Anshuman Khandual wrote:
> On 03/07/2017 12:06 PM, Minchan Kim wrote:
> > With the discussion[1], I found it seems there are every PageFlags
> > functions return bool at this moment so we don't need double
> > negation any more.
> > Although it's not a problem to keep it, it makes future users
> > confused to use dobule negation for them, too.
> > 
> > Remove such possibility.
> 
> A quick search of '!!Page' in the source tree does not show any other
> place having this double negation. So I guess this is all which need
> to be fixed.

Yeb. That's the why my patch includes only khugepagd part but my
concern is PageFlags returns int type not boolean so user might
be confused easily and tempted to use dobule negation.

Other side is they who create new custom PageXXX(e.g., PageMovable)
should keep it in mind that they should return 0 or 1 although
fucntion prototype's return value is int type. It shouldn't be
documented nowhere. Although we can add a little description
somewhere in page-flags.h, I believe changing to boolean is more
clear/not-error-prone so Chen's work is enough worth, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
