Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f176.google.com (mail-yw0-f176.google.com [209.85.161.176])
	by kanga.kvack.org (Postfix) with ESMTP id 30DBB6B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:43:33 -0500 (EST)
Received: by mail-yw0-f176.google.com with SMTP id i131so29968865ywc.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:43:33 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id t188si1094674ywd.26.2016.03.04.04.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 04:43:32 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id p65so224372ywb.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:43:32 -0800 (PST)
Date: Fri, 4 Mar 2016 07:43:31 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] mm: percpu: Use pr_fmt to prefix output
Message-ID: <20160304124331.GD13868@htj.duckdns.org>
References: <cover.1457047399.git.joe@perches.com>
 <ddb59cbebc26211964c1e45d3d4251d76ae851ab.1457047399.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddb59cbebc26211964c1e45d3d4251d76ae851ab.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 03, 2016 at 03:25:34PM -0800, Joe Perches wrote:
> Use the normal mechanism to make the logging output consistently
> "percpu: " instead of a mix of "PERCPU: " and "percpu: "
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Tejun Heo <tj@kernel.org>

Andrew, I think it'd be best to route this one with the rest of the
series through -mm.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
