Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 89201280012
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 11:28:34 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gq15so7861327lab.7
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 08:28:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si17685544wie.6.2014.11.10.08.28.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 08:28:31 -0800 (PST)
Date: Mon, 10 Nov 2014 16:28:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 -next 00/10] mm: improve usage of the i_mmap lock
Message-ID: <20141110162827.GA21422@suse.de>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Thu, Oct 30, 2014 at 12:34:07PM -0700, Davidlohr Bueso wrote:
> Changes from v1:
>  o Collected Acks from Kirill and Srikar.
>  o Updated to apply on top of linux-next.
> 

FWIW, I looked at all the patches when looking at the hugetlbfs sharing
part and while it was not a very detailed review, I also did not see
anything bad so for patches 1-7, 9 and 11

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
