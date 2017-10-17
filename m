Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E02A6B0069
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:22:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v127so749153wma.3
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:22:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v23sor4403202eda.27.2017.10.17.04.22.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 04:22:16 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:22:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: rename page dtor functions to
 {compound,huge,transhuge}_page__dtor
Message-ID: <20171017112214.n5emzjzstmbktn6m@node.shutemov.name>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-3-git-send-email-changbin.du@intel.com>
 <20171017102203.u2v3p2ivuogu4rk6@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171017102203.u2v3p2ivuogu4rk6@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 17, 2017 at 12:22:03PM +0200, Michal Hocko wrote:
> On Mon 16-10-17 17:19:17, changbin.du@intel.com wrote:
> > From: Changbin Du <changbin.du@intel.com>
> > 
> > The current name free_{huge,transhuge}_page are paired with
> > alloc_{huge,transhuge}_page functions, but the actual page free
> > function is still free_page() which will indirectly call
> > free_{huge,transhuge}_page. So this patch removes this confusion
> > by renaming all the compound page dtors.
> 
> Is this code churn really worth it?

Getting naming straight is kinda nit. :)

But I don't feel strong either way.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
