Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id 10D5F6B0039
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:48:41 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so14734851qen.15
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:48:40 -0800 (PST)
Received: from mail-qa0-x236.google.com (mail-qa0-x236.google.com [2607:f8b0:400d:c00::236])
        by mx.google.com with ESMTPS id t9si38050415qed.87.2013.12.03.14.48.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 14:48:40 -0800 (PST)
Received: by mail-qa0-f54.google.com with SMTP id f11so6131945qae.13
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:48:39 -0800 (PST)
Date: Tue, 3 Dec 2013 17:48:36 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 00/23] mm: Use memblock interface instead of bootmem
Message-ID: <20131203224836.GR8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>

FYI, the series is missing the first patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
