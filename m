Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B93CE6B04D8
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:18:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g63-v6so9843170pfc.9
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 01:18:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e11-v6si24264030pln.21.2018.10.30.01.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 01:17:59 -0700 (PDT)
Date: Tue, 30 Oct 2018 09:17:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181030081757.GX32673@dhcp22.suse.cz>
References: <20181029141210.GJ32673@dhcp22.suse.cz>
 <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
 <20181029163528.GL32673@dhcp22.suse.cz>
 <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
 <20181029172415.GM32673@dhcp22.suse.cz>
 <8e7a4311a240b241822945c0bb4095c9ffe5a14d.camel@linux.intel.com>
 <20181029181827.GO32673@dhcp22.suse.cz>
 <3281f3044fa231bbc1b02d5c5efca3502a0d05a8.camel@linux.intel.com>
 <20181030062915.GT32673@dhcp22.suse.cz>
 <CAPcyv4itSde5oiW2j5uK8PCqdpXkHKz=kS8NBk2Ge+Ldb=yLUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4itSde5oiW2j5uK8PCqdpXkHKz=kS8NBk2Ge+Ldb=yLUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, osalvador@techadventures.net

On Mon 29-10-18 23:55:12, Dan Williams wrote:
> On Mon, Oct 29, 2018 at 11:29 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 29-10-18 12:59:11, Alexander Duyck wrote:
> > > On Mon, 2018-10-29 at 19:18 +0100, Michal Hocko wrote:
> [..]
> > > The patches Andrew pushed addressed the immediate issue so that now
> > > systems with nvdimm/DAX memory can at least initialize quick enough
> > > that systemd doesn't refuse to mount the root file system due to a
> > > timeout.
> >
> > This is about the first time you actually mention that. I have re-read
> > the cover letter and all changelogs of patches in this serious. Unless I
> > have missed something there is nothing about real users hitting issues
> > out there. nvdimm is still considered a toy because there is no real HW
> > users can play with.
> 
> Yes, you have missed something, because that's incorrect. There's been
> public articles about these parts sampling since May.
> 
>     https://www.anandtech.com/show/12828/intel-launches-optane-dimms-up-to-512gb-apache-pass-is-here

indeed!

> That testing identified this initialization performance problem and
> thankfully got it addressed in time for the current merge window.

And I still cannot see a word about that in changelogs.

-- 
Michal Hocko
SUSE Labs
