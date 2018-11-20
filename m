Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B35E26B206C
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:26:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so1350244edd.11
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:26:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m48-v6si1806130edc.43.2018.11.20.06.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:26:00 -0800 (PST)
Date: Tue, 20 Nov 2018 15:25:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
Message-ID: <20181120142559.GM22247@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
 <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
 <20181120141207.GK22247@dhcp22.suse.cz>
 <20181120141700.pwoaxatx3v5xnwos@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120141700.pwoaxatx3v5xnwos@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 20-11-18 17:17:00, Kirill A. Shutemov wrote:
> On Tue, Nov 20, 2018 at 03:12:07PM +0100, Michal Hocko wrote:
> > On Tue 20-11-18 17:07:15, Kirill A. Shutemov wrote:
> > > On Tue, Nov 20, 2018 at 02:43:23PM +0100, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > filemap_map_pages takes a speculative reference to each page in the
> > > > range before it tries to lock that page. While this is correct it
> > > > also can influence page migration which will bail out when seeing
> > > > an elevated reference count. The faultaround code would bail on
> > > > seeing a locked page so we can pro-actively check the PageLocked
> > > > bit before page_cache_get_speculative and prevent from pointless
> > > > reference count churn.
> > > 
> > > Looks fine to me.
> > 
> > Thanks for the review.
> > 
> > > But please drop a line of comment in the code. As is it might be confusing
> > > for a reader.
> > 
> > This?
> 
> Yep.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Cool, thanks! I will wait some more time for review feedback for other
patches and then repost with this folded in.

-- 
Michal Hocko
SUSE Labs
