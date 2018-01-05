Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9B376B0506
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:27:51 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 79so5284388ion.20
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:27:51 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id j68si4928648itg.5.2018.01.05.11.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 11:27:50 -0800 (PST)
Date: Fri, 5 Jan 2018 13:27:48 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
In-Reply-To: <20180105184808.GS2801@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1801051326490.28069@nuc-kabylake>
References: <20180103082555.14592-1-mhocko@kernel.org> <20180103082555.14592-2-mhocko@kernel.org> <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com> <20180105091443.GJ2801@dhcp22.suse.cz> <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
 <20180105093301.GK2801@dhcp22.suse.cz> <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake> <20180105180905.GR2801@dhcp22.suse.cz> <alpine.DEB.2.20.1801051237300.26065@nuc-kabylake> <20180105184808.GS2801@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 5 Jan 2018, Michal Hocko wrote:

> > Also why are you migrating the pages on pagelist if a
> > add_page_for_migration() fails? One could simply update
> > the status in user space and continue.
>
> I am open to further cleanups. Care to send a full patch with the
> changelog? I would rather not fold more changes to the already tested
> one.

While doing that I saw that one could pull the rwsem locking out of
add_page_for_migration() as well in order to avoid taking it for each 4k
page. Include that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
