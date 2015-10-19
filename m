Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E076D82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:30:54 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so20171882pad.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:30:54 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id hg4si50288137pac.145.2015.10.18.23.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 23:30:54 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so181397144pab.0
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:30:54 -0700 (PDT)
Date: Mon, 19 Oct 2015 15:33:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH mmotm] mm: dont split thp page when syscall is called fix
 4
Message-ID: <20151019063357.GA963@bbox>
References: <alpine.LSU.2.11.1510161540460.31102@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510161540460.31102@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Hugh,

On Fri, Oct 16, 2015 at 03:46:03PM -0700, Hugh Dickins wrote:
> Compiler gives helpful warnings that madvise_free_pte_range()
> has the args to split_huge_pmd() the wrong way round.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thanks for catching my mistake.

Reviewed-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
