Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B705B6B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:31:53 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so16063570wib.6
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:31:50 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id x16si41774024wiv.50.2014.07.07.08.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 08:31:49 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 7 Jul 2014 16:31:49 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9A5C517D805A
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 16:33:19 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s67FVkmg30867524
	for <linux-mm@kvack.org>; Mon, 7 Jul 2014 15:31:46 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s67FVifE018634
	for <linux-mm@kvack.org>; Mon, 7 Jul 2014 09:31:46 -0600
Date: Mon, 7 Jul 2014 17:31:43 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v10 5/7] s390: add pmd_[dirty|mkclean] for THP
Message-ID: <20140707173143.271bbd52@thinkpad>
In-Reply-To: <1404694438-10272-6-git-send-email-minchan@kernel.org>
References: <1404694438-10272-1-git-send-email-minchan@kernel.org>
	<1404694438-10272-6-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill
 A. Shutemov" <kirill@shutemov.name>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-s390@vger.kernel.org

On Mon,  7 Jul 2014 09:53:56 +0900
Minchan Kim <minchan@kernel.org> wrote:

> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page but for s390 pmds only referenced bit is available
> because there is no free bit left in the pmd entry for the
> software dirty bit so this patch adds dumb pmd_dirty which
> returns always true by suggesting by Martin.
> 
> They finally find a solution in future.
> http://marc.info/?l=linux-api&m=140440328820808&w=2
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: linux-s390@vger.kernel.org
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  arch/s390/include/asm/pgtable.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)

Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
