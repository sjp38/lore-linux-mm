Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7AB6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:00:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y39so704233wrd.17
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:00:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g206si6964833wmg.269.2017.10.17.05.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 05:00:23 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:00:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: rename page dtor functions to
 {compound,huge,transhuge}_page__dtor
Message-ID: <20171017120022.m4gblhcfs7xf7zld@dhcp22.suse.cz>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-3-git-send-email-changbin.du@intel.com>
 <20171017102203.u2v3p2ivuogu4rk6@dhcp22.suse.cz>
 <20171017112214.n5emzjzstmbktn6m@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171017112214.n5emzjzstmbktn6m@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-10-17 14:22:14, Kirill A. Shutemov wrote:
> On Tue, Oct 17, 2017 at 12:22:03PM +0200, Michal Hocko wrote:
> > On Mon 16-10-17 17:19:17, changbin.du@intel.com wrote:
> > > From: Changbin Du <changbin.du@intel.com>
> > > 
> > > The current name free_{huge,transhuge}_page are paired with
> > > alloc_{huge,transhuge}_page functions, but the actual page free
> > > function is still free_page() which will indirectly call
> > > free_{huge,transhuge}_page. So this patch removes this confusion
> > > by renaming all the compound page dtors.
> > 
> > Is this code churn really worth it?
> 
> Getting naming straight is kinda nit. :)

yes

> But I don't feel strong either way.

Me neither, I am just trying to understand why the patch has been
created? Is it a preparation for some other changes? If it was removing
some code it would be much more clear but it actually adds twice as much
as it removes so it doesn't save anything there. It makes the API more
explicit which might be good but is it worth that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
