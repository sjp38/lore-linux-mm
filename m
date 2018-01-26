Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84C4A6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 21:18:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id h5so5884701pgv.21
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:18:48 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 3-v6si2937542plt.307.2018.01.25.18.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jan 2018 18:18:46 -0800 (PST)
Date: Fri, 26 Jan 2018 13:18:37 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2018-01-25-16-20 uploaded
Message-ID: <20180126131837.232ddd26@canb.auug.org.au>
In-Reply-To: <5a6a748d.knotXn2H0hp7I43s%akpm@linux-foundation.org>
References: <5a6a748d.knotXn2H0hp7I43s%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Thu, 25 Jan 2018 16:21:33 -0800 akpm@linux-foundation.org wrote:
>
> * include-linux-mtd-rawnandh-fix-build-with-gcc-444.patch

This one clashed with a similar (but not identical) commit in another
tree, so I dropped it.

> * net-sched-sch_prioc-work-around-gcc-444-union-initializer-issues.patch

This patch turned up in another tree, so I dropped it as well.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
