Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24BDC6B034D
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 09:09:26 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o16so652563wmf.4
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 06:09:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si871440wrd.327.2018.01.03.06.09.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 06:09:25 -0800 (PST)
Date: Wed, 3 Jan 2018 15:09:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, migrate: remove reason argument from new_page_t
Message-ID: <20180103140923.GD11319@dhcp22.suse.cz>
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-3-mhocko@kernel.org>
 <f31b8830-db49-05a2-9a64-d27476fd206c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f31b8830-db49-05a2-9a64-d27476fd206c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 03-01-18 19:30:38, Anshuman Khandual wrote:
> On 01/03/2018 01:55 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > No allocation callback is using this argument anymore. new_page_node
> > used to use this parameter to convey node_id resp. migration error
> > up to move_pages code (do_move_page_to_node_array). The error status
> > never made it into the final status field and we have a better way
> > to communicate node id to the status field now. All other allocation
> > callbacks simply ignored the argument so we can drop it finally.
> 
> There is a migrate_pages() call in powerpc which needs to be changed
> as well. It was failing the build on powerpc.

Yes, see http://lkml.kernel.org/r/20180103091134.GB11319@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
