Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 880F76B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 20:15:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j70so62199553pge.11
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 17:15:55 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id k5si3281886pln.108.2017.03.30.17.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 Mar 2017 17:15:54 -0700 (PDT)
Date: Fri, 31 Mar 2017 11:15:49 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-03-30-16-31 uploaded
Message-ID: <20170331111549.4095877d@canb.auug.org.au>
In-Reply-To: <58dd956b.QgnkRmcTNdLnV9Cm%akpm@linux-foundation.org>
References: <58dd956b.QgnkRmcTNdLnV9Cm%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Thu, 30 Mar 2017 16:31:55 -0700 akpm@linux-foundation.org wrote:
>
> * mm-page_alloc-split-smallest-stolen-page-in-fallback-fix.patch

The above patch has an "Author:" header rather than a "From:" header
and so "git am" chokes on it.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
