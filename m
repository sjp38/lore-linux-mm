Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A34816B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 13:22:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f5so18405708pff.13
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 10:22:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y16si10314817pli.71.2017.04.12.10.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 10:22:00 -0700 (PDT)
Date: Wed, 12 Apr 2017 10:21:58 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170412172158.GF784@bombadil.infradead.org>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
 <20170328175408.GD7838@bombadil.infradead.org>
 <20170329080625.GC27994@dhcp22.suse.cz>
 <20170329174514.GB4543@tassilo.jf.intel.com>
 <20170330061245.GA1972@dhcp22.suse.cz>
 <20170412161829.GA16422@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170412161829.GA16422@linux-80c1.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Wed, Apr 12, 2017 at 09:18:29AM -0700, Davidlohr Bueso wrote:
> On Thu, 30 Mar 2017, Michal Hocko wrote:
> 
> > On Wed 29-03-17 10:45:14, Andi Kleen wrote:
> > > On Wed, Mar 29, 2017 at 10:06:25AM +0200, Michal Hocko wrote:
> > > >
> > > > Do we actually have any users?
> > > 
> > > Yes this feature is widely used.
> > 
> > Considering that none of SHM_HUGE* has been exported to the userspace
> > headers all the users would have to use the this flag by the value and I
> > am quite skeptical that application actually do that. Could you point me
> > to some projects that use this?
> 
> Hmm Andrew, if there's not one example, could you please pick up this patch?

Please comment on the replacement patch I suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
