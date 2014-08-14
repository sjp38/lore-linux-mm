Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE7C6B0072
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 12:10:05 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id u10so1012214lbd.21
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 09:10:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si8687088lae.16.2014.08.14.09.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 09:10:03 -0700 (PDT)
Date: Thu, 14 Aug 2014 18:10:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.16 branch opened for mm git tree (was: Re: mmotm
 2014-08-13-14-29 uploaded)
Message-ID: <20140814161001.GB19405@dhcp22.suse.cz>
References: <53ebd904.2Mcm8776rCbhNYjx%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53ebd904.2Mcm8776rCbhNYjx%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-3.16 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.16 tag in Linus tree and mmotm-2014-08-13-14-29.

I have pulled some cgroup wide changes from Tejun on top.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
