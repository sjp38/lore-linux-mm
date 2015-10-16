Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 092AF82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 16:48:28 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so25644047wic.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:48:27 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id cm4si14767363wjb.78.2015.10.16.13.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 13:48:26 -0700 (PDT)
Received: by wijp11 with SMTP id p11so26505584wij.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:48:26 -0700 (PDT)
Date: Fri, 16 Oct 2015 23:48:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] memcg: include linux/mm.h
Message-ID: <20151016204825.GB1817@node.shutemov.name>
References: <14714191.7FdLxZ8X79@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14714191.7FdLxZ8X79@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Oct 16, 2015 at 10:03:31PM +0200, Arnd Bergmann wrote:
> A recent change to the memcg code added a call to virt_to_head_page,
> which is declared in linux/mm.h, but this is not necessarily included
> here and will cause compile errors:
> 
> include/linux/memcontrol.h:841:9: error: implicit declaration of function 'virt_to_head_page' [-Werror=implicit-function-declaration]
> 
> This adds an explicit include statement that gets rid of the error.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 1ead4c071978 ("memcg: simplify and inline __mem_cgroup_from_kmem")

http://lkml.kernel.org/g/20151016131726.GA602@node.shutemov.name

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
