Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 223B36B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 22:37:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c9so21783769ioj.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:37:20 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p1si16393046iof.121.2016.05.19.19.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 19:37:19 -0700 (PDT)
Date: Fri, 20 May 2016 12:37:15 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2016-05-19-18-01 uploaded
Message-ID: <20160520123715.191726f5@canb.auug.org.au>
In-Reply-To: <573e6218.YQH2A+YBUHmPqyvU%akpm@linux-foundation.org>
References: <573e6218.YQH2A+YBUHmPqyvU%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Thu, 19 May 2016 18:02:16 -0700 akpm@linux-foundation.org wrote:
>
> The mm-of-the-moment snapshot 2016-05-19-18-01 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
	.
	.
>   mm-page_alloc-defer-debugging-checks-of-pages-allocated-from-the-pcp.patch
>   mm-page_alloc-dont-duplicate-code-in-free_pcp_prepare.patch
>   mm-page_alloc-uninline-the-bad-page-part-of-check_new_page.patch
>   mm-page_alloc-restore-the-original-nodemask-if-the-fast-path-allocation-failed.patch

Is that all there is?  No linux-next patch?

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
