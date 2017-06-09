Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 889B36B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 18:38:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c75so19988307pfk.3
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 15:38:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y19sor1547543pgj.126.2017.06.09.15.38.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 15:38:45 -0700 (PDT)
Date: Fri, 9 Jun 2017 15:38:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Sleeping BUG in khugepaged for i586
In-Reply-To: <20170608203046.GB5535@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706091537020.66176@chino.kir.corp.google.com>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net> <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org> <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz> <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net> <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com> <20170608144831.GA19903@dhcp22.suse.cz> <20170608170557.GA8118@bombadil.infradead.org> <20170608201822.GA5535@dhcp22.suse.cz> <20170608203046.GB5535@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 8 Jun 2017, Michal Hocko wrote:

> I would just pull the cond_resched out of __collapse_huge_page_copy
> right after pte_unmap. But I am not really sure why this cond_resched is
> really needed because the changelog of the patch which adds is is quite
> terse on details.

I'm not sure what could possibly be added to the changelog.  We have 
encountered need_resched warnings during the iteration.  We fix these 
because need_resched warnings suppress future warnings of the same type 
for issues that are more important.

I can fix the i386 issue but removing the cond_resched() entirely isn't 
really suitable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
