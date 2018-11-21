Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 311F76B24C1
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:07:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so2073665edc.13
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:07:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10-v6si533685ejp.291.2018.11.20.23.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 23:07:27 -0800 (PST)
Date: Wed, 21 Nov 2018 08:07:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
Message-ID: <20181121070726.GC12932@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
 <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
 <20181120141207.GK22247@dhcp22.suse.cz>
 <29F15A96-D6EB-450E-B54B-A4CB460ED9B3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29F15A96-D6EB-450E-B54B-A4CB460ED9B3@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 20-11-18 21:51:39, William Kucharski wrote:
> 
> 
> > On Nov 20, 2018, at 7:12 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > +		/*
> > +		 * Check the locked pages before taking a reference to not
> > +		 * go in the way of migration.
> > +		 */
> 
> Could you make this a tiny bit more explanative, something like:
> 
> +		/*
> +		 * Check for a locked page first, as a speculative
> +		 * reference may adversely influence page migration.
> +		 */

sure

> 
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>

Thanks!

-- 
Michal Hocko
SUSE Labs
