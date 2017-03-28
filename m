Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 670FB6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:53:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u2so513761wmu.18
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:53:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i57si5309732wra.111.2017.03.28.09.53.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 09:53:53 -0700 (PDT)
Date: Tue, 28 Mar 2017 09:53:43 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170328165343.GB27446@linux-80c1.suse>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

Do we have any consensus here? Keeping SHM_HUGE_* is currently
winning 2-1. If there are in fact users out there computing the
value manually, then I am ok with keeping it and properly exporting
it. Michal?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
