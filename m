Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f175.google.com (mail-gg0-f175.google.com [209.85.161.175])
	by kanga.kvack.org (Postfix) with ESMTP id 905E86B0036
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:33:06 -0500 (EST)
Received: by mail-gg0-f175.google.com with SMTP id c2so98107ggn.34
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:33:06 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id g6si4494119qab.39.2014.01.08.23.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 23:33:05 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Thu, 9 Jan 2014 00:33:04 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0E4593E40026
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 00:33:02 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s097WoA97602622
	for <linux-mm@kvack.org>; Thu, 9 Jan 2014 08:32:50 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s097X1Pk009789
	for <linux-mm@kvack.org>; Thu, 9 Jan 2014 00:33:01 -0700
Date: Thu, 9 Jan 2014 15:32:59 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140109073259.GK4106@localhost.localdomain>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
 <20140108101611.GD27937@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140108101611.GD27937@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

On Wed, Jan 08, 2014 at 11:16:11AM +0100, Michal Hocko wrote:
> On Wed 08-01-14 16:20:01, Han Pingtian wrote:
> > On Mon, Jan 06, 2014 at 05:46:04PM +0100, Michal Hocko wrote:
> > > On Sun 05-01-14 08:35:01, Han Pingtian wrote:
> > > [...]
> > > > From f4d085a880dfae7638b33c242554efb0afc0852b Mon Sep 17 00:00:00 2001
> > > > From: Han Pingtian <hanpt@linux.vnet.ibm.com>
> > > > Date: Fri, 3 Jan 2014 11:10:49 +0800
> > > > Subject: [PATCH] mm: show message when raising min_free_kbytes in THP
> > > > 
> > > > min_free_kbytes may be raised during THP's initialization. Sometimes,
> > > > this will change the value being set by user. Showing message will
> > > > clarify this confusion.
> > > 
> > > I do not have anything against informing about changing value
> > > set by user but this will inform also when the default value is
> > > updated. Is this what you want? Don't you want to check against
> > > user_min_free_kbytes? (0 if not set by user)
> > > 
> > 
> > To use user_min_free_kbytes in mm/huge_memory.c, we need a 
> > 
> >     extern int user_min_free_kbytes;
> 
> The variable is not defined as static so you can use it outside of
> mm/page_alloc.c.
> 
> > in somewhere? Where should we put it? I guess it is mm/internal.h,
> > right?
> 
> I do not think this has to be globaly visible though. Why not just
> extern declaration in mm/huge_memory.c?
> 

This is the new patch, please review. Thanks.
