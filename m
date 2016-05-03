Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64E1E6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 06:07:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so14723162wme.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 03:07:53 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id 10si1629790lfb.93.2016.05.03.03.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 03:07:51 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id u64so15868084lff.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 03:07:51 -0700 (PDT)
Date: Tue, 3 May 2016 13:07:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160503100748.GA31787@node.shutemov.name>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <572766A7.9090406@suse.cz>
 <20160502150109.GB24419@node.shutemov.name>
 <572776EF.2070804@intel.com>
 <20160502160250.GD24419@node.shutemov.name>
 <20160503073757.GA28046@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160503073757.GA28046@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Tue, May 03, 2016 at 09:37:57AM +0200, Michal Hocko wrote:
> On Mon 02-05-16 19:02:50, Kirill A. Shutemov wrote:
> > On Mon, May 02, 2016 at 08:49:03AM -0700, Dave Hansen wrote:
> > > On 05/02/2016 08:01 AM, Kirill A. Shutemov wrote:
> > > > On Mon, May 02, 2016 at 04:39:35PM +0200, Vlastimil Babka wrote:
> > > >> On 04/27/2016 07:11 PM, Dave Hansen wrote:
> > > >>> 6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
> > > >>>    severity of the problem.
> > > >>
> > > >> I think that makes sense. Being large already amortizes the cost per base
> > > >> page much more than pagevecs do (512 vs ~22 pages?).
> > > > 
> > > > We try to do this already, don't we? Any spefic case where we have THPs on
> > > > pagevecs?
> > > 
> > > Lukas was hitting this on a RHEL 7 era kernel.  In his kernel at least,
> > > I'm pretty sure THP's were ending up on pagevecs.  Are you saying you
> > > don't think we're doing that any more?
> > 
> > As Vlastimil pointed, we do. It need to be fixed, I think.
> 
> It seems that offloading the draining to the vmstat context doesn't look
> terribly bad. Don't we rather want to go that way?

Maybe. My knowledge about lru cache is limited.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
