Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2CCF6810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:36:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p8so1393237wrf.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:36:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w19si3759117wra.295.2017.08.25.14.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:36:22 -0700 (PDT)
Date: Fri, 25 Aug 2017 14:36:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
Message-Id: <20170825143620.582a8822f80431b4baacd8ee@linux-foundation.org>
In-Reply-To: <20170824060957.GA29811@dhcp22.suse.cz>
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
	<20170824060957.GA29811@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ebiggers@google.com, aarcange@redhat.com, dvyukov@google.com, hughd@google.com, minchan@kernel.org, rientjes@google.com, stable@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Aug 2017 08:09:57 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > Google Bug Id: 64696096
> 
> Is this necessary in the changelog?

I tend to keep this sort of a thing as a courtesy to the sender.

But I did change it from "Google-Bug-Id:". 
Documentation/process/submitting-patches.rst lists "Reported-by:,
Tested-by:, Reviewed-by:, Suggested-by: and Fixes:" as the recognized
patch tags and I don't think it's a good idea to introduce new ones -
that just creates more work for the people who maintain parsers for
this stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
