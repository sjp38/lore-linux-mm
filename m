Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A95C58E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:12:39 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w19so17440355qto.13
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:12:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor76112401qtc.32.2019.01.11.10.12.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 10:12:38 -0800 (PST)
Message-ID: <1547230356.6911.23.camel@lca.pw>
Subject: Re: [PATCH] rbtree: fix the red root
From: Qian Cai <cai@lca.pw>
Date: Fri, 11 Jan 2019 13:12:36 -0500
In-Reply-To: <20190111173132.GH6310@bombadil.infradead.org>
References: 
	<YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
	 <20190111165145.23628-1-cai@lca.pw>
	 <20190111173132.GH6310@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, walken@google.com, David.Woodhouse@intel.com

On Fri, 2019-01-11 at 09:31 -0800, Matthew Wilcox wrote:
> On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> > Reported-by: Esme <esploit@protonmail.ch>
> > Signed-off-by: Qian Cai <cai@lca.pw>
> 
> What change introduced this bug?  We need a Fixes: line so the stable
> people know how far to backport this fix.

It looks like,

Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
necessary)

where it no longer always paint the root as black.

Also, copying this fix for the original author and reviewer.

https://lore.kernel.org/lkml/20190111165145.23628-1-cai@lca.pw/
