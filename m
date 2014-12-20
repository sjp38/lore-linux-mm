Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B77016B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:17:59 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so2625215wgh.1
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 16:17:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id az9si6005794wib.86.2014.12.19.16.17.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 16:17:58 -0800 (PST)
Date: Fri, 19 Dec 2014 16:17:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-Id: <20141219161756.bcf7421acb4bc7a286c1afa3@linux-foundation.org>
In-Reply-To: <20141220001043.GC11975@blaptop>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
	<20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
	<20141219233937.GA11975@blaptop>
	<20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
	<20141219235852.GB11975@blaptop>
	<20141219160648.5cea8a6b0c764caa6100a585@linux-foundation.org>
	<20141220001043.GC11975@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 20 Dec 2014 09:10:43 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > It involves rehashing a lengthy argument with Greg.
> 
> Okay. Then, Ganesh,
> please add warn message about duplicaed name possibility althoug
> it's unlikely as it is.

Oh, getting EEXIST is easy with this patch.  Just create and destroy a
pool 2^32 times and the counter wraps ;) It's hardly a serious issue
for a debugging patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
