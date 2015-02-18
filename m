Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 02CC26B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 19:02:52 -0500 (EST)
Received: by pdjy10 with SMTP id y10so47249272pdj.6
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 16:02:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mm8si904784pbc.198.2015.02.17.16.02.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 16:02:51 -0800 (PST)
Date: Tue, 17 Feb 2015 16:02:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm, hugetlb: set PageLRU for in-use/active hugepages
Message-Id: <20150217160249.7d498e4bd0837748e8c6a5f0@linux-foundation.org>
In-Reply-To: <20150217155744.04db5a98d5a1820240eb2317@linux-foundation.org>
References: <1424143299-7557-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20150217093153.GA12875@hori1.linux.bs1.fc.nec.co.jp>
	<20150217155744.04db5a98d5a1820240eb2317@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 17 Feb 2015 15:57:44 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> So if I'm understanding this correctly, hugepages never have PG_lru set
> and so you are overloading that bit on hugepages to indicate that the
> page is present on hstate->hugepage_activelist?

And maybe we don't need to overload PG_lru at all?  There's plenty of
free space in the compound page's *(page + 1).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
