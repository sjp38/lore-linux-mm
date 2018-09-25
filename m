Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31B158E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:00:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x19-v6so13319756pfh.15
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:00:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37-v6sor438954pgm.152.2018.09.25.14.00.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 14:00:08 -0700 (PDT)
Date: Wed, 26 Sep 2018 00:00:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Disable movable allocation for TRANSHUGE pages
Message-ID: <20180925210001.j4olzx3fru4jpfys@kshutemo-mobl1>
References: <1537860333-28416-1-git-send-email-amhetre@nvidia.com>
 <20180925115153.z5b5ekijf5jzhzmn@kshutemo-mobl1>
 <20180925183019.GB22630@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925183019.GB22630@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ashish Mhetre <amhetre@nvidia.com>, linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

On Tue, Sep 25, 2018 at 08:30:19PM +0200, Michal Hocko wrote:
> On Tue 25-09-18 14:51:53, Kirill A. Shutemov wrote:
> > On Tue, Sep 25, 2018 at 12:55:33PM +0530, Ashish Mhetre wrote:
> > > TRANSHUGE pages have no migration support.
> > 
> > Transparent pages have migration support since v4.14.
> 
> This is true but not for all architectures AFAICS. In fact git grep
> suggests that only x86 supports the migration. So unless I am missing
> something the patch has some merit.

THP pages are movable from the beginning. Before 4.14, the cost of
migration was THP split. From my PoV __GFP_MOVABLE is justified and we
should keep it there.

-- 
 Kirill A. Shutemov
