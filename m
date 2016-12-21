Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5F06B03AD
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 09:52:54 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gl16so8427256wjc.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 06:52:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr7si27822596wjb.113.2016.12.21.06.52.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 06:52:53 -0800 (PST)
Date: Wed, 21 Dec 2016 15:52:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161221145249.GL31118@dhcp22.suse.cz>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
 <20161219152156.GC5175@dhcp22.suse.cz>
 <20161220164823.GB13224@vultr.guest>
 <20161221075115.GE16502@dhcp22.suse.cz>
 <20161221131332.GB23096@vultr.guest>
 <20161221132200.GK31118@dhcp22.suse.cz>
 <20161221143956.GA23331@vultr.guest>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221143956.GA23331@vultr.guest>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-12-16 14:39:56, Wei Yang wrote:
> On Wed, Dec 21, 2016 at 02:22:01PM +0100, Michal Hocko wrote:
[...]
> >Anyway this all should be part of the changelog.
> 
> Ok, let me add this in changelog in next version.

Then make sure to document how it could happen and how realistic such a
scenario is.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
