Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0C4B28026C
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 12:15:21 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id d62so5077255iof.0
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 09:15:21 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id j63si4741580itb.37.2018.01.05.09.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 09:15:20 -0800 (PST)
Date: Fri, 5 Jan 2018 11:15:18 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
In-Reply-To: <20180105093301.GK2801@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake>
References: <20180103082555.14592-1-mhocko@kernel.org> <20180103082555.14592-2-mhocko@kernel.org> <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com> <20180105091443.GJ2801@dhcp22.suse.cz> <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
 <20180105093301.GK2801@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 5 Jan 2018, Michal Hocko wrote:

> Yes. I am really wondering because there souldn't anything specific to
> improve the situation with patch 2 and 3. Likewise the only overhead
> from the patch 1 I can see is the reduced batching of the mmap_sem. But
> then I am wondering what would compensate that later...

Could you reduce the frequency of taking mmap_sem? Maybe take it when
picking a new node and drop it when done with that node before migrating
the list of pages?

There is the potential of large amounts of pages being migrated and
having to take a semaphore on every one of them would create a nice amount
of overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
