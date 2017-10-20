Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57BAA6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:08:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o44so5754985wrf.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 06:08:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 71si798031wrl.427.2017.10.20.06.08.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 06:08:46 -0700 (PDT)
Date: Fri, 20 Oct 2017 15:08:45 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [rfc 2/2] smaps: Show zone device memory used
Message-ID: <20171020130845.m5sodqlqktrcxkks@dhcp22.suse.cz>
References: <20171018063123.21983-1-bsingharora@gmail.com>
 <20171018063123.21983-2-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018063123.21983-2-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: jglisse@redhat.com, linux-mm@kvack.org

On Wed 18-10-17 17:31:23, Balbir Singh wrote:
> With HMM, we can have either public or private zone
> device pages. With private zone device pages, they should
> show up as swapped entities. For public zone device pages
> the smaps output can be confusing and incomplete.
> 
> This patch adds a new attribute to just smaps to show
> device memory usage.

As this will become user API which we will have to maintain for ever I
would really like to hear about who is going to use this information and
what for.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
