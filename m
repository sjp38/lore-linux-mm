Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A26A3280704
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:53:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w14so2687617wrc.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:53:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w194si2707874wme.82.2017.08.23.23.53.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 23:53:53 -0700 (PDT)
Date: Thu, 24 Aug 2017 08:53:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
Message-ID: <20170824065349.GE29811@dhcp22.suse.cz>
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
 <20170824060957.GA29811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824060957.GA29811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ebiggers@google.com, aarcange@redhat.com, dvyukov@google.com, hughd@google.com, minchan@kernel.org, rientjes@google.com, stable@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 24-08-17 08:09:57, Michal Hocko wrote:
> Hmm, I do not see this neither in linux-mm nor LKML. Strange

Not strange, just my filters fooled me. Sorry about the confusion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
