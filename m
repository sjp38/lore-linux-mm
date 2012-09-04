Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A835C6B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 15:16:00 -0400 (EDT)
Received: by dadi14 with SMTP id i14so4913834dad.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 12:16:00 -0700 (PDT)
Date: Tue, 4 Sep 2012 12:16:01 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/memblock: Replace 0 with NULL for pointer
Message-ID: <20120904191601.GB6180@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346747105-658-1-git-send-email-sachin.kamat@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346747105-658-1-git-send-email-sachin.kamat@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sachin Kamat <sachin.kamat@linaro.org>
Cc: linux-mm@kvack.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

On Tue, Sep 04, 2012 at 01:55:05PM +0530, Sachin Kamat wrote:
> Silences the following sparse warning:
> mm/memblock.c:249:49: warning: Using plain integer as NULL pointer
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
