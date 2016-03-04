Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 404636B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:41:58 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id z13so22244107ykd.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:41:58 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id k7si1078674ywf.306.2016.03.04.04.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 04:41:57 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id p65so222512ywb.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:41:57 -0800 (PST)
Date: Fri, 4 Mar 2016 07:41:55 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/4] mm: Coalesce split strings
Message-ID: <20160304124155.GB13868@htj.duckdns.org>
References: <cover.1457047399.git.joe@perches.com>
 <8bc1865b2af7472be1cfc3728fe310f288083779.1457047399.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8bc1865b2af7472be1cfc3728fe310f288083779.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 03, 2016 at 03:25:32PM -0800, Joe Perches wrote:
> Kernel style prefers a single string over split strings when
> the string is 'user-visible'.
> 
> Miscellanea:
> 
> o Add a missing newline
> o Realign arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>

For percpu,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
