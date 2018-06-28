Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60A326B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 09:12:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k18-v6so2974733wrn.8
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 06:12:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1-v6sor3214012wri.78.2018.06.28.06.12.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 06:12:54 -0700 (PDT)
Date: Thu, 28 Jun 2018 15:12:52 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v6 4/5] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-ID: <20180628131252.GB13985@techadventures.net>
References: <20180628062857.29658-1-bhe@redhat.com>
 <20180628062857.29658-5-bhe@redhat.com>
 <20180628120937.GC12956@techadventures.net>
 <CAGM2reZsZVhhg2=dQZf6D-NmPTFRN-_95+s61pC7Axz5G5mkMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZsZVhhg2=dQZf6D-NmPTFRN-_95+s61pC7Axz5G5mkMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On Thu, Jun 28, 2018 at 08:12:04AM -0400, Pavel Tatashin wrote:
> > > +             if (nr_consumed_maps >= nr_present_sections) {
> > > +                     pr_err("nr_consumed_maps goes beyond nr_present_sections\n");
> > > +                     break;
> > > +             }
> >
> > Hi Baoquan,
> >
> > I am sure I am missing something here, but is this check really needed?
> >
> > I mean, for_each_present_section_nr() only returns the section nr if the section
> > has been marked as SECTION_MARKED_PRESENT.
> > That happens in memory_present(), where now we also increment nr_present_sections whenever
> > we find a present section.
> >
> > So, for_each_present_section_nr() should return the same nr of section as nr_present_sections.
> > Since we only increment nr_consumed_maps once in the loop, I am not so sure we can
> > go beyond nr_present_sections.
> >
> > Did I overlook something?
> 
> You did not, this is basically a safety check. A BUG_ON() would be
> better here. As, this something that should really not happening, and
> would mean a bug in the current project.

I think we would be better off having a BUG_ON() there.
Otherwise the system can go sideways later on. 

-- 
Oscar Salvador
SUSE L3
