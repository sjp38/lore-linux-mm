Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8306B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:35:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x78so13255399pff.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 05:35:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u31si4076627pgn.98.2017.09.25.05.35.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 05:35:12 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:35:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
Message-ID: <20170925123508.pzjbe7wgwagnr5li@dhcp22.suse.cz>
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
 <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
 <fb013ae6-6f47-248b-db8b-a0abae530377@redhat.com>
 <ee87215d-9704-7269-4ec1-226f2e32a751@oracle.com>
 <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

On Tue 19-09-17 14:11:19, Florian Weimer wrote:
> On 09/18/2017 07:11 PM, Mike Kravetz wrote:
[...]
> > I can drop this wording, but would still like to suggest memfd_create as
> > the preferred method of creating duplicate mappings.  It would be good if
> > others on Cc: could comment as well.
> 
> mremap seems to work with non-anonymous mappings, too:

only for shared mappings in fact. Because once we have CoW then mremap
will not provide you with the same content as the original mapping.

[...]

> > Just curious, does glibc make use of this today?  Or, is this just something
> > that you think may be useful.
> 
> To my knowledge, we do not use this today.  But it certainly looks very
> useful.

What would be the usecase. I mean why don't you simply create a new
mapping by a plain mmap when you have no guarantee about the same
content?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
