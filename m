Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5640D6B0010
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:29:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t17-v6so1350365edr.21
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 00:29:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11-v6si2237739edq.75.2018.07.24.00.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 00:29:39 -0700 (PDT)
Date: Tue, 24 Jul 2018 09:29:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init
 for ZONE_DEVICE
Message-ID: <20180724072937.GD28386@dhcp22.suse.cz>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
 <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
 <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
 <20180717155006.GL7193@dhcp22.suse.cz>
 <CAA9_cmez_vrjBYvcpXT_5ziQ2CqRFzPbEWMO2kdmjW0rWhkaCA@mail.gmail.com>
 <20180718120529.GY7193@dhcp22.suse.cz>
 <3f43729d-fd4e-a488-e04d-026ef5a28dd9@intel.com>
 <20180723110928.GC31229@dhcp22.suse.cz>
 <510a1213-e391-bad6-4239-60fa477aaac0@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510a1213-e391-bad6-4239-60fa477aaac0@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@oracle.com, dalias@libc.org, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, the arch/x86 maintainers <x86@kernel.org>, Matthew Wilcox <willy@infradead.org>, daniel.m.jordan@oracle.com, Ingo Molnar <mingo@redhat.com>, fenghua.yu@intel.com, Jerome Glisse <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "Luck, Tony" <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Mon 23-07-18 09:15:32, Dave Hansen wrote:
> On 07/23/2018 04:09 AM, Michal Hocko wrote:
> > On Thu 19-07-18 11:41:10, Dave Hansen wrote:
> >> Are you looking for the actual end-user reports?  This was more of a
> >> case of the customer plugging in some persistent memory DIMMs, noticing
> >> the boot delta and calling the folks who sold them the DIMMs (Intel).
> > But this doesn't sound like something to rush a solution for in the
> > upcoming merge windown, does it?
> 
> No, we should not rush it.  We'll try to rework it properly.

Thanks a lot Dave! I definitely do not mean to block this at all. I just
really do not like to have the code even more cluttered than we have
now.
-- 
Michal Hocko
SUSE Labs
