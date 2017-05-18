Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF946831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 05:08:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q91so7881532wrb.8
        for <linux-mm@kvack.org>; Thu, 18 May 2017 02:08:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q55si4804035edd.130.2017.05.18.02.08.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 02:08:51 -0700 (PDT)
Date: Thu, 18 May 2017 11:08:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
Message-ID: <20170518090846.GD25462@dhcp22.suse.cz>
References: <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
 <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
 <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org>
 <20170517092042.GH18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
 <20170517140501.GM18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org>
 <20170517145645.GO18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Wed 17-05-17 10:25:09, Cristopher Lameter wrote:
> On Wed, 17 May 2017, Michal Hocko wrote:
> 
> > > If you have screwy things like static mbinds in there then you are
> > > hopelessly lost anyways. You may have moved the process to another set
> > > of nodes but the static bindings may refer to a node no longer
> > > available. Thus the OOM is legitimate.
> >
> > The point is that you do _not_ want such a process to trigger the OOM
> > because it can cause other processes being killed.
> 
> Nope. The OOM in a cpuset gets the process doing the alloc killed. Or what
> that changed?
> 
> At this point you have messed up royally and nothing is going to rescue
> you anyways. OOM or not does not matter anymore. The app will fail.

Not really. If you can trick the system to _think_ that the intersection
between mempolicy and the cpuset is empty then the OOM killer might
trigger an innocent task rather than the one which tricked it into that
situation.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
