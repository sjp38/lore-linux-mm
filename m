Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9631A6B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 03:44:02 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id bs8so10142877wib.15
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 00:44:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dl6si7111910wib.12.2014.08.07.00.44.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 00:44:01 -0700 (PDT)
Date: Thu, 7 Aug 2014 09:44:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm-memcontrol-rewrite-charge-api.patch and
 mm-memcontrol-rewrite-uncharge-api.patch
Message-ID: <20140807074400.GA12730@dhcp22.suse.cz>
References: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Wed 06-08-14 13:59:14, Andrew Morton wrote:
> 
> Do we feel these are ready for merging?

Yes, let's go with it. I do not think that waiting for the next cycle
will help much.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
