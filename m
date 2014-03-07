Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1726A6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 21:03:18 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so3351125pdi.7
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 18:03:17 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id f1si6682309pbn.16.2014.03.06.18.03.15
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 18:03:17 -0800 (PST)
Date: Fri, 7 Mar 2014 11:03:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Fix URL for zsmalloc benchmark
Message-ID: <20140307020314.GB3787@bbox>
References: <1394157629.2861.42.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394157629.2861.42.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: linux-mm@kvack.org

On Fri, Mar 07, 2014 at 02:00:29AM +0000, Ben Hutchings wrote:
> The help text for CONFIG_PGTABLE_MAPPING has an incorrect URL.
> While we're at it, remove the unnecessary footnote notation.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
