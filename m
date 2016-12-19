Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 420C46B0289
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:29:04 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n68so81749654itn.4
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 02:29:04 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id z99si9679977ita.0.2016.12.19.02.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 02:29:03 -0800 (PST)
Date: Mon, 19 Dec 2016 11:29:04 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
Message-ID: <20161219102904.GD3107@twins.programming.kicks-ass.net>
References: <20161218123229.22952-1-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161218123229.22952-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org



For all 4,

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
