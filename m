Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1E56B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 19:07:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p126so504721oih.2
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 16:07:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t10si478266oib.20.2017.09.22.16.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 16:07:42 -0700 (PDT)
Message-ID: <1506121660.21121.76.camel@redhat.com>
Subject: Re: [PATCH] mm: madvise: add description for MADV_WIPEONFORK and
 MADV_KEEPONFORK
From: Rik van Riel <riel@redhat.com>
Date: Fri, 22 Sep 2017 19:07:40 -0400
In-Reply-To: <1506117328-88228-1-git-send-email-yang.s@alibaba-inc.com>
References: <1506117328-88228-1-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 2017-09-23 at 05:55 +0800, Yang Shi wrote:
> mm/madvise.c has the brief description about all MADV_ flags, added
> the
> description for the newly added MADV_WIPEONFORK and MADV_KEEPONFORK.
> 
> Although man page has the similar information, but it'd better to
> keep the
> consistency with other flags.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> 
Thank you for spotting that I missed a location!

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
