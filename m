Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 128E68E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:11:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d28-v6so15889edb.17
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:11:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q25-v6si30177edi.5.2018.09.25.14.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 14:11:25 -0700 (PDT)
Date: Tue, 25 Sep 2018 23:11:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Disable movable allocation for TRANSHUGE pages
Message-ID: <20180925211123.GZ18685@dhcp22.suse.cz>
References: <1537860333-28416-1-git-send-email-amhetre@nvidia.com>
 <20180925115153.z5b5ekijf5jzhzmn@kshutemo-mobl1>
 <20180925183019.GB22630@dhcp22.suse.cz>
 <20180925210001.j4olzx3fru4jpfys@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925210001.j4olzx3fru4jpfys@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ashish Mhetre <amhetre@nvidia.com>, linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

On Wed 26-09-18 00:00:02, Kirill A. Shutemov wrote:
> On Tue, Sep 25, 2018 at 08:30:19PM +0200, Michal Hocko wrote:
> > On Tue 25-09-18 14:51:53, Kirill A. Shutemov wrote:
> > > On Tue, Sep 25, 2018 at 12:55:33PM +0530, Ashish Mhetre wrote:
> > > > TRANSHUGE pages have no migration support.
> > > 
> > > Transparent pages have migration support since v4.14.
> > 
> > This is true but not for all architectures AFAICS. In fact git grep
> > suggests that only x86 supports the migration. So unless I am missing
> > something the patch has some merit.
> 
> THP pages are movable from the beginning. Before 4.14, the cost of
> migration was THP split. From my PoV __GFP_MOVABLE is justified and we
> should keep it there.

A very good point! I haven't really looked closer to what happens in the
cma/migration code when the migration is not supported. As you've said
THP migt be split into 4kB pages and those are migrateable by
definition. So I take back my proposal and if this doesn't work properly
now then it should really be handled by splitting up the thp.

Thanks and sorry I've missed this!
-- 
Michal Hocko
SUSE Labs
