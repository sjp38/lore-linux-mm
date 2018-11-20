Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E750C6B205D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:07:23 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so1301286pgb.10
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:07:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d27sor42062193pgm.9.2018.11.20.06.07.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 06:07:22 -0800 (PST)
Date: Tue, 20 Nov 2018 17:07:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
Message-ID: <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120134323.13007-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Nov 20, 2018 at 02:43:23PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> filemap_map_pages takes a speculative reference to each page in the
> range before it tries to lock that page. While this is correct it
> also can influence page migration which will bail out when seeing
> an elevated reference count. The faultaround code would bail on
> seeing a locked page so we can pro-actively check the PageLocked
> bit before page_cache_get_speculative and prevent from pointless
> reference count churn.

Looks fine to me.

But please drop a line of comment in the code. As is it might be confusing
for a reader.

-- 
 Kirill A. Shutemov
