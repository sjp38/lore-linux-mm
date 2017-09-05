Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C14C328030E
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 03:37:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p14so3044192wrg.7
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 00:37:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si58753wrc.485.2017.09.05.00.37.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 00:37:33 -0700 (PDT)
Date: Tue, 5 Sep 2017 09:37:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, sparse: fix typo in online_mem_sections
Message-ID: <20170905073730.4reirga47o4athse@dhcp22.suse.cz>
References: <20170904112210.3401-1-mhocko@kernel.org>
 <4d648f70-325d-3f60-8620-94c232b380d8@linux.vnet.ibm.com>
 <20170905072836.i4dxrukevojty4ub@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170905072836.i4dxrukevojty4ub@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 05-09-17 09:28:36, Michal Hocko wrote:
> On Tue 05-09-17 12:32:28, Anshuman Khandual wrote:
> > On 09/04/2017 04:52 PM, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > online_mem_sections accidentally marks online only the first section in
> > > the given range. This is a typo which hasn't been noticed because I
> > > haven't tested large 2GB blocks previously. All users of
> > 
> > Section sizes are normally less than 2GB. Could you please elaborate
> > why this never got noticed before ?
> 
> Section size is 128MB which is the default block size as well. So we
> have one section per block. But if the amount of memory is very large
> (64GB - see probe_memory_block_size) then we have a 2GB memory blocks
> so multiple sections per block.

And just to clarify. Not that 64G would be too large but the original
patch has been merged in 4.13 so nobody probably managed to hit that
_yet_.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
