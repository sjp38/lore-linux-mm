Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A6E136B0254
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:03:38 -0500 (EST)
Received: by pasz6 with SMTP id z6so94531455pas.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 23:03:38 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id fk1si25482976pad.35.2015.11.12.23.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Nov 2015 23:03:37 -0800 (PST)
Date: Fri, 13 Nov 2015 16:03:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Message-ID: <20151113070356.GG5235@bbox>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
 <564421DA.9060809@gmail.com>
 <20151113061511.GB5235@bbox>
 <56458056.8020105@gmail.com>
 <20151113063802.GF5235@bbox>
 <56458720.4010400@gmail.com>
MIME-Version: 1.0
In-Reply-To: <56458720.4010400@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

On Fri, Nov 13, 2015 at 01:45:52AM -0500, Daniel Micay wrote:
> > And now I am thinking if we use access bit, we could implment MADV_FREE_UNDO
> > easily when we need it. Maybe, that's what you want. Right?
> 
> Yes, but why the access bit instead of the dirty bit for that? It could
> always be made more strict (i.e. access bit) in the future, while going
> the other way won't be possible. So I think the dirty bit is really the
> more conservative choice since if it turns out to be a mistake it can be
> fixed without a backwards incompatible change.

Absolutely true. That's why I insist on dirty bit until now although
I didn't tell the reason. But I thought you wanted to change for using
access bit for the future, too. It seems MADV_FREE start to bloat
over and over again before knowing real problems and usecases.
It's almost same situation with volatile ranges so I really want to
stop at proper point which maintainer should decide, I hope.
Without it, we will make the feature a lot heavy by just brain storming
and then causes lots of churn in MM code without real bebenfit
It would be very painful for us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
