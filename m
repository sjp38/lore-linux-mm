Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9386B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:52:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11so15814142pfk.23
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 01:52:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si3781821plo.828.2017.10.23.01.52.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 01:52:16 -0700 (PDT)
Date: Mon, 23 Oct 2017 10:52:13 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [rfc 1/2] mm/hmm: Allow smaps to see zone device public pages
Message-ID: <20171023085213.xryytzlt7yvjctc2@dhcp22.suse.cz>
References: <20171018063123.21983-1-bsingharora@gmail.com>
 <20171020131142.z7kxvmlukg4z2shv@dhcp22.suse.cz>
 <CAKTCnzn4oh1807rwm3yF4THgn79ps35_OKcOTmKA8wfw=KULaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzn4oh1807rwm3yF4THgn79ps35_OKcOTmKA8wfw=KULaw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>

On Sat 21-10-17 08:52:27, Balbir Singh wrote:
> On Sat, Oct 21, 2017 at 12:11 AM, Michal Hocko <mhocko@suse.com> wrote:
> > On Wed 18-10-17 17:31:22, Balbir Singh wrote:
> >> vm_normal_page() normally does not return zone device public
> >> pages. In the absence of the visibility the output from smaps
> >> is limited and confusing. It's hard to figure out where the
> >> pages are. This patch uses _vm_normal_page() to expose them
> >> for accounting
> >
> > Maybe I am missing something but does this patch make any sense without
> > patch 2? If no why they are not folded into a single one?
> 
> 
> I can fold them into one patch. The first patch when applied will just provide
> visibility and they'll show as regular resident pages. The second patch
> then accounts only for them being device memory.

Hmm, I am not really sure. It makes some sense to account mapped HMM
pages as RSS but then I am wondering how HMM differs from other special
mappings (like VM_PFNMAP or VM_MIXEDMAP)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
