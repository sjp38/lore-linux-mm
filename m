Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 18B506B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:08:28 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b67so52844568qgb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:08:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s63si10284666qhs.29.2016.02.25.15.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 15:08:27 -0800 (PST)
Date: Fri, 26 Feb 2016 00:08:24 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160225230824.GG1180@redhat.com>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
 <20160225195613.GZ2854@techsingularity.net>
 <20160225230219.GF1180@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225230219.GF1180@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Feb 26, 2016 at 12:02:19AM +0100, Andrea Arcangeli wrote:
> Let's first agree if direct compaction is going to hurt also for the
> MADV_HUGEPAGE case. I say MADV_HUGEPAGE benefits from direct
> compaction and is not hurt by not doing direct compaction. If you
                    ^^^ drop this not sorry for any confusion :)
> agree with this concept, I'd ask to change your patch, because your
> patch in turn is hurting MADV_HUGEPAGE users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
