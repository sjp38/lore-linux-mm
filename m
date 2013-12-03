Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id C4AE46B004D
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:54:21 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so6113992qae.20
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:54:21 -0800 (PST)
Received: from mail-qe0-x22a.google.com (mail-qe0-x22a.google.com [2607:f8b0:400d:c02::22a])
        by mx.google.com with ESMTPS id c9si3007183qab.12.2013.12.03.14.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 14:54:21 -0800 (PST)
Received: by mail-qe0-f42.google.com with SMTP id b4so14864513qen.1
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:54:20 -0800 (PST)
Date: Tue, 3 Dec 2013 17:54:17 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 04/23] mm/memory_hotplug: remove unnecessary inclusion
 of bootmem.h
Message-ID: <20131203225417.GU8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-5-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-5-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 02, 2013 at 09:27:19PM -0500, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> Clean-up to remove depedency with bootmem headers.
> 
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
