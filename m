Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 09BAA6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 05:16:13 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so705170eaj.26
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 02:16:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si13314400eew.79.2014.01.08.02.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 02:16:13 -0800 (PST)
Date: Wed, 8 Jan 2014 11:16:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140108101611.GD27937@dhcp22.suse.cz>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
 <20140108082000.GJ4106@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140108082000.GJ4106@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed 08-01-14 16:20:01, Han Pingtian wrote:
> On Mon, Jan 06, 2014 at 05:46:04PM +0100, Michal Hocko wrote:
> > On Sun 05-01-14 08:35:01, Han Pingtian wrote:
> > [...]
> > > From f4d085a880dfae7638b33c242554efb0afc0852b Mon Sep 17 00:00:00 2001
> > > From: Han Pingtian <hanpt@linux.vnet.ibm.com>
> > > Date: Fri, 3 Jan 2014 11:10:49 +0800
> > > Subject: [PATCH] mm: show message when raising min_free_kbytes in THP
> > > 
> > > min_free_kbytes may be raised during THP's initialization. Sometimes,
> > > this will change the value being set by user. Showing message will
> > > clarify this confusion.
> > 
> > I do not have anything against informing about changing value
> > set by user but this will inform also when the default value is
> > updated. Is this what you want? Don't you want to check against
> > user_min_free_kbytes? (0 if not set by user)
> > 
> 
> To use user_min_free_kbytes in mm/huge_memory.c, we need a 
> 
>     extern int user_min_free_kbytes;

The variable is not defined as static so you can use it outside of
mm/page_alloc.c.

> in somewhere? Where should we put it? I guess it is mm/internal.h,
> right?

I do not think this has to be globaly visible though. Why not just
extern declaration in mm/huge_memory.c?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
