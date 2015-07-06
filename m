Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9E02802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:46:04 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so161423702wid.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:46:04 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id jc5si52248967wic.74.2015.07.06.06.46.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 06:46:03 -0700 (PDT)
Received: by wguu7 with SMTP id u7so141014789wgu.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:46:02 -0700 (PDT)
Date: Mon, 6 Jul 2015 15:45:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] TLB flush multiple pages per IPI v7
Message-ID: <20150706134559.GB8094@gmail.com>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436189996-7220-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> This is hopefully the final version that was agreed on. Ingo, you had sent
> an ack but I had to add a new arch helper after that for accounting purposes
> and there was a new patch added for the swap cluster suggestion. With the
> changes I did not include the ack just in case it was no longer valid.

The series still looks very good to me:

  Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks Mel!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
