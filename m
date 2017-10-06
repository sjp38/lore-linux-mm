Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D83C56B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 05:56:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u78so15217483wmd.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 02:56:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m28sor787892eda.12.2017.10.06.02.56.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 02:56:41 -0700 (PDT)
Date: Fri, 6 Oct 2017 12:56:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] mm: Introduce wrappers to access mm->nr_ptes
Message-ID: <20171006095639.7zrc5s7vv6syukb4@node.shutemov.name>
References: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
 <20171006085038.hhjqfys63x5aotda@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171006085038.hhjqfys63x5aotda@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Fri, Oct 06, 2017 at 10:50:38AM +0200, Michal Hocko wrote:
> On Thu 05-10-17 13:14:41, Kirill A. Shutemov wrote:
> > Let's add wrappers for ->nr_ptes with the same interface as for nr_pmd
> > and nr_pud.
> > 
> > It's preparation for consolidation of page-table counters in mm_struct.
> 
> You are also making the accounting dependent on MMU which is OK because
> no nommu arch really accounts page tables if there is anything like that
> at all on those archs but it should be mentioned in the changelog.

Okay, I'll update change log.

> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
