Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3018B6B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:12:17 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y42so8638780wrd.23
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:12:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l21si1907593wmb.100.2017.11.21.14.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:12:16 -0800 (PST)
Date: Tue, 21 Nov 2017 14:12:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Message-Id: <20171121141213.89db86bfbd75c22fc0209990@linux-foundation.org>
In-Reply-To: <20171121021855.50525-1-zi.yan@sent.com>
References: <20171121021855.50525-1-zi.yan@sent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Reale <ar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

On Mon, 20 Nov 2017 21:18:55 -0500 Zi Yan <zi.yan@sent.com> wrote:

> In [1], Andrea reported that during memory hotplug/hot remove
> prep_transhuge_page() is called incorrectly on non-THP pages for
> migration, when THP is on but THP migration is not enabled.
> This leads to a bad state of target pages for migration.
> 
> This patch fixes it by only calling prep_transhuge_page() when we are
> certain that the target page is THP.

What are the user-visible effects of the bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
