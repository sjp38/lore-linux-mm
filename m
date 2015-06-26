Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5070E6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 13:28:44 -0400 (EDT)
Received: by wiga1 with SMTP id a1so23318728wig.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 10:28:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si4060959wix.19.2015.06.26.10.28.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 10:28:42 -0700 (PDT)
Message-ID: <1435339686.15762.2.camel@stgolabs.net>
Subject: Re: [PATCH] mm:Make the function vma_has_reserves bool
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 26 Jun 2015 10:28:06 -0700
In-Reply-To: <1435335335-16007-1-git-send-email-xerofoify@gmail.com>
References: <1435335335-16007-1-git-send-email-xerofoify@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, rientjes@google.com, mike.kravetz@oracle.com, lcapitulino@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2015-06-26 at 12:15 -0400, Nicholas Krause wrote:
> This makes the function vma_has_reserves bool now due to this
> particular function only returning either one or zero as its
> return value.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  mm/hugetlb.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c

Yeah, don't be sending one patch per function change for this kind of
crap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
