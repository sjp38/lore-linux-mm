Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B76FF6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 08:16:22 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hi5so818052wib.14
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 05:16:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id sd12si2263178wjb.172.2014.02.07.05.16.21
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 05:16:21 -0800 (PST)
Message-ID: <52F4DC9B.5050201@redhat.com>
Date: Fri, 07 Feb 2014 08:16:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/9] mm: Mark function as static in mmap.c
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <a2b21fa8852f0ee5c8da179240142e5f084154e9.1391167128.git.rashika.kheria@gmail.com>
In-Reply-To: <a2b21fa8852f0ee5c8da179240142e5f084154e9.1391167128.git.rashika.kheria@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, josh@joshtriplett.org

On 02/07/2014 07:04 AM, Rashika Kheria wrote:
> Mark function as static in mmap.c because they are not used outside this
> file.
> 
> This eliminates the following warning in mm/mmap.c:
> mm/mmap.c:407:6: warning: no previous prototype for a??validate_mma?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
