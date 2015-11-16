Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3790C6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:55:11 -0500 (EST)
Received: by ykba77 with SMTP id a77so244928116ykb.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:55:10 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id t131si6602628ywa.67.2015.11.16.07.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 07:55:10 -0800 (PST)
Received: by ykba77 with SMTP id a77so244927261ykb.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:55:10 -0800 (PST)
Date: Mon, 16 Nov 2015 10:55:06 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] percpu: remove PERCPU_ENOUGH_ROOM which is stale
 definition
Message-ID: <20151116155506.GC18894@mtj.duckdns.org>
References: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: cl@linux.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 04, 2015 at 01:26:07PM +0000, Jungseok Lee wrote:
> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
> used any more. That is, no code refers to the definition.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>

Applied to percpu/for-4.5.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
