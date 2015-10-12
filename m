Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id BD7D46B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:12:15 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so153104068wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:12:15 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id hg7si16563451wib.23.2015.10.12.08.12.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:12:13 -0700 (PDT)
Received: by wijq8 with SMTP id q8so62586994wij.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:12:13 -0700 (PDT)
Date: Mon, 12 Oct 2015 17:12:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: containers: how to limit pagecache size?
Message-ID: <20151012151212.GB19838@dhcp22.suse.cz>
References: <56176365.2010606@mogujie.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56176365.2010606@mogujie.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuzhou <yuzhou@mogujie.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com

On Fri 09-10-15 14:49:09, Yuzhou wrote:
> Hi, all
> 
> How to limit and reclaim container's pagecache?

There is no way to reclaim only the page cache. What you can do is to
put excessive page cache consumers into a separate memory cgroup and
limit them that way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
