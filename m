Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E24A6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:49:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so6797713pgu.22
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:49:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si8647720pgu.368.2017.10.19.05.49.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:49:34 -0700 (PDT)
Date: Thu, 19 Oct 2017 14:49:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171019124931.p5zdvs2kdwu73mwh@dhcp22.suse.cz>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
 <20171017102052.ltc2lb6r7kloazgs@dhcp22.suse.cz>
 <20171018110026.GA4352@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018110026.GA4352@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Du, Changbin" <changbin.du@intel.com>
Cc: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 18-10-17 19:00:26, Du, Changbin wrote:
> Hi Hocko,
> 
> On Tue, Oct 17, 2017 at 12:20:52PM +0200, Michal Hocko wrote:
> > [CC Kirill]
> > 
> > On Mon 16-10-17 17:19:16, changbin.du@intel.com wrote:
> > > From: Changbin Du <changbin.du@intel.com>
> > > 
> > > This patch introduced 4 new interfaces to allocate a prepared
> > > transparent huge page.
> > >   - alloc_transhuge_page_vma
> > >   - alloc_transhuge_page_nodemask
> > >   - alloc_transhuge_page_node
> > >   - alloc_transhuge_page
> > > 
> > > The aim is to remove duplicated code and simplify transparent
> > > huge page allocation. These are similar to alloc_hugepage_xxx
> > > which are for hugetlbfs pages. This patch does below changes:
> > >   - define alloc_transhuge_page_xxx interfaces
> > >   - apply them to all existing code
> > >   - declare prep_transhuge_page as static since no others use it
> > >   - remove alloc_hugepage_vma definition since it no longer has users
> > 
> > So what exactly is the advantage of the new API? The diffstat doesn't
> > sound very convincing to me.
> >
> The caller only need one step to allocate thp. Several LOCs removed for all the
> caller side with this change. So it's little more convinent.

Yeah, but the overall result is more code. So I am not really convinced. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
