Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f178.google.com (mail-yw0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1EE6B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:41:08 -0500 (EST)
Received: by mail-yw0-f178.google.com with SMTP id h129so43234842ywb.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:41:08 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id e189si1079414ywd.377.2016.03.04.04.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 04:41:07 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id s188so2853264ywe.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:41:07 -0800 (PST)
Date: Fri, 4 Mar 2016 07:41:05 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/4] mm: Convert pr_warning to pr_warn
Message-ID: <20160304124105.GA13868@htj.duckdns.org>
References: <cover.1457047399.git.joe@perches.com>
 <4d7b3004d1715ddf86c821527a334615ac2dfdf4.1457047399.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d7b3004d1715ddf86c821527a334615ac2dfdf4.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 03, 2016 at 03:25:31PM -0800, Joe Perches wrote:
> There are a mixture of pr_warning and pr_warn uses in mm.
> Use pr_warn consistently.
> 
> Miscellanea:
> 
> o Coalesce formats
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
