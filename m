Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id D51166B0036
	for <linux-mm@kvack.org>; Sat, 16 Aug 2014 08:59:37 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so3139654qgf.34
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 05:59:37 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id l4si16283579qaf.97.2014.08.16.05.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 16 Aug 2014 05:59:37 -0700 (PDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so3139044qgf.31
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 05:59:37 -0700 (PDT)
Date: Sat, 16 Aug 2014 08:59:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] Free percpu allocation info for uniprocessor system
Message-ID: <20140816125934.GG9305@htj.dyndns.org>
References: <1407850575-18794-1-git-send-email-enjoymindful@gmail.com>
 <1407850575-18794-2-git-send-email-enjoymindful@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407850575-18794-2-git-send-email-enjoymindful@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Honggang Li <enjoymindful@gmail.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, user-mode-linux-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org

On Tue, Aug 12, 2014 at 09:36:15PM +0800, Honggang Li wrote:
> Currently, only SMP system free the percpu allocation info.
> Uniprocessor system should free it too. For example, one x86 UML
> virtual machine with 256MB memory, UML kernel wastes one page memory.
> 
> Signed-off-by: Honggang Li <enjoymindful@gmail.com>

Applied to percpu/for-3.17-fixes w/ stable cc'd.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
