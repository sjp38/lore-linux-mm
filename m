Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 60CC86B003B
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 00:41:50 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so8278903pad.35
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 21:41:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id m9si18875545pab.32.2014.03.10.21.41.48
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 21:41:49 -0700 (PDT)
Date: Mon, 10 Mar 2014 21:46:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: bad rss-counter message in 3.14rc5
Message-Id: <20140310214612.3b4de36a.akpm@linux-foundation.org>
In-Reply-To: <20140310201340.81994295.akpm@linux-foundation.org>
References: <20140305174503.GA16335@redhat.com>
	<20140305175725.GB16335@redhat.com>
	<20140307002210.GA26603@redhat.com>
	<20140311024906.GA9191@redhat.com>
	<20140310201340.81994295.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Mon, 10 Mar 2014 20:13:40 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> > Anyone ? I'm hitting this trace on an almost daily basis, which is a pain
> > while trying to reproduce a different bug..
> 
> Damn, I thought we'd fixed that but it seems not.  Cc's added.
> 
> Guys, what stops the migration target page from coming unlocked in
> parallel with zap_pte_range()'s call to migration_entry_to_page()?

page_table_lock, sort-of.  At least, transitions of is_migration_entry()
and page_locked() happen under ptl.

I don't see any holes in regular migration.  Do you know if this is
reproducible with CONFIG_NUMA_BALANCING=n or CONFIG_NUMA=n?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
