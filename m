Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id D6E326B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 09:57:24 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id hw13so7115464qab.32
        for <linux-mm@kvack.org>; Mon, 12 May 2014 06:57:24 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id c4si6009169qad.26.2014.05.12.06.57.23
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 06:57:24 -0700 (PDT)
Date: Mon, 12 May 2014 08:57:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: use a irq-safe __mod_zone_page_state in
 mlocked_vma_newpage()
In-Reply-To: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
Message-ID: <alpine.DEB.2.10.1405120855470.3090@gentwo.org>
References: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, zhangyanfei@cn.fujitsu.com, hanpt@linux.vnet.ibm.com, sasha.levin@oracle.com, oleg@redhat.com, fabf@skynet.be, mgorman@suse.de, aarcange@redhat.com, cldu@marvell.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 10 May 2014, Jianyu Zhan wrote:

> mlocked_vma_newpage() is only called in fault path by
> page_add_new_anon_rmap(), which is called on a *new* page.
> And such page is initially only visible via the pagetables, and the
> pte is locked while calling page_add_new_anon_rmap(), so we need not
> use an irq-safe mod_zone_page_state() here, using a light-weight version
> __mod_zone_page_state() would be OK.

This has nothing to do with the safety of statistics operations that work
on different data structures. Which leads to the conclusion that
__mod_page_state cannot be used here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
