Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 158336B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 03:20:09 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so282723yha.17
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 00:20:08 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id 44si139891yhf.112.2014.01.08.00.20.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 00:20:08 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 01:20:07 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7EDAC19D8041
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 01:19:55 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s088JtX28847808
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 09:19:55 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s088K3Oc016849
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 01:20:03 -0700
Date: Wed, 8 Jan 2014 16:20:01 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140108082000.GJ4106@localhost.localdomain>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106164604.GC27602@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Jan 06, 2014 at 05:46:04PM +0100, Michal Hocko wrote:
> On Sun 05-01-14 08:35:01, Han Pingtian wrote:
> [...]
> > From f4d085a880dfae7638b33c242554efb0afc0852b Mon Sep 17 00:00:00 2001
> > From: Han Pingtian <hanpt@linux.vnet.ibm.com>
> > Date: Fri, 3 Jan 2014 11:10:49 +0800
> > Subject: [PATCH] mm: show message when raising min_free_kbytes in THP
> > 
> > min_free_kbytes may be raised during THP's initialization. Sometimes,
> > this will change the value being set by user. Showing message will
> > clarify this confusion.
> 
> I do not have anything against informing about changing value
> set by user but this will inform also when the default value is
> updated. Is this what you want? Don't you want to check against
> user_min_free_kbytes? (0 if not set by user)
> 

To use user_min_free_kbytes in mm/huge_memory.c, we need a 

    extern int user_min_free_kbytes;

in somewhere? Where should we put it? I guess it is mm/internal.h,
right?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
