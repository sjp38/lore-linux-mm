Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 52C2D6B0002
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 05:00:41 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id d13so3939697eaa.0
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 02:00:39 -0800 (PST)
Date: Thu, 24 Jan 2013 11:00:35 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/1] mm: fix wrong comments about anon_vma lock
Message-ID: <20130124100035.GB26351@gmail.com>
References: <1359019310-23555-1-git-send-email-yuanhan.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359019310-23555-1-git-send-email-yuanhan.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuanhan Liu <yuanhan.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org


* Yuanhan Liu <yuanhan.liu@linux.intel.com> wrote:

> We use rwsem since commit 5a50508. And most of comments are converted to
> the new rwsem lock; while just 2 more missed from:
> 	 $ git grep 'anon_vma->mutex'
> 
> Cc: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
