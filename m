Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id CB95B6B0037
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:56:23 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so4617217qge.36
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:56:23 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id e10si2048750qco.33.2014.05.09.08.56.23
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 08:56:23 -0700 (PDT)
Date: Fri, 9 May 2014 10:56:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: use a irq-safe __mod_zone_page_state in
 mlocked_vma_newpage()
In-Reply-To: <1399648668-17420-1-git-send-email-nasa4836@gmail.com>
Message-ID: <alpine.DEB.2.10.1405091050520.11318@gentwo.org>
References: <1399648668-17420-1-git-send-email-nasa4836@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, aarcange@redhat.com, hanpt@linux.vnet.ibm.com, mgorman@suse.de, oleg@redhat.com, cldu@marvell.com, fabf@skynet.be, sasha.levin@oracle.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Fri, 9 May 2014, Jianyu Zhan wrote:

> mlocked_vma_newpage() is only called in fault path by
> page_add_new_anon_rmap(), which is called on a *new* page.
> And such page is initially only visible via the pagetables, and the
> pte is locked while calling page_add_new_anon_rmap(), so we could use
> a irq-safe version of __mod_zone_page_state() here.

You are changing from the irq safe variant to __mod_zone_page_state which
is *not* irq safe. Its legit to do so since presumably irqs are disabled
anyways so you do not have to worry about irq safeness of
__mod_zone_page_state.

Please update the description. Its a bit confusing right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
