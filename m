Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 694966B00B4
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 20:19:34 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n6U0JcYU001272
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 17:19:38 -0700
Received: from wf-out-1314.google.com (wfa28.prod.google.com [10.142.1.28])
	by zps78.corp.google.com with ESMTP id n6U0JYfx026362
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 17:19:36 -0700
Received: by wf-out-1314.google.com with SMTP id 28so325071wfa.13
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 17:19:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090729114322.GA9335@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
Date: Wed, 29 Jul 2009 17:19:34 -0700
Message-ID: <33307c790907291719r2caf7914xb543877464ba6fc2@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

BTW, can you explain this code at the bottom of generic_sync_sb_inodes
for me?

                if (wbc->nr_to_write <= 0) {
                        wbc->more_io = 1;
                        break;
                }

I don't understand why we are setting more_io here? AFAICS, more_io
means there's more stuff to write ... I would think we'd set this if
nr_to_write was > 0 ?

Or just have the section below brought up above this
break check and do:

if (!list_empty(&sb->s_more_io) || !list_empty(&sb->s_io))
        wbc->more_io = 1;

Am I just misunderstanding the intent of more_io ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
