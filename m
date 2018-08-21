Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC0946B209A
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:43:21 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t4-v6so12312231plo.0
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:43:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r7-v6si12952948pgh.473.2018.08.21.13.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 13:43:20 -0700 (PDT)
Date: Tue, 21 Aug 2018 13:43:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/4] Refactoring for
 remove_memory_section/unregister_mem_sect_under_nodes
Message-Id: <20180821134318.f743b6c58f2b5a91e17e596e@linux-foundation.org>
In-Reply-To: <20180821162122.GA10300@techadventures.net>
References: <20180817090017.17610-1-osalvador@techadventures.net>
	<20180821162122.GA10300@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, 21 Aug 2018 18:21:22 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:

> On Fri, Aug 17, 2018 at 11:00:13AM +0200, Oscar Salvador wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > v3 -> v4:
> >         - Make nodemask_t a stack variable
> >         - Added Reviewed-by from David and Pavel
> > 
> > v2 -> v3:
> >         - NODEMASK_FREE can deal with NULL pointers, so do not
> >           make it conditional (by David).
> >         - Split up node_online's check patch (David's suggestion)
> >         - Added Reviewed-by from Andrew and David
> >         - Fix checkpath.pl warnings
> 
> Andrew, will you pick up this patchset?
> I saw that v3 was removed from the -mm tree because it was about
> to be updated with a new version (this one), but I am not sure if
> anything wrong happened.

Yes, things are still changing and we're late in the merge window.  I
decided to park it and shall take it up again after 4.19-rc1.
