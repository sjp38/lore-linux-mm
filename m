Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2A98E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:16:09 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so10915395pfi.9
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:16:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x5si16263760pgq.535.2019.01.11.10.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 10:16:08 -0800 (PST)
Date: Fri, 11 Jan 2019 10:16:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] rbtree: fix the red root
Message-ID: <20190111181600.GJ6310@bombadil.infradead.org>
References: <YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
 <20190111165145.23628-1-cai@lca.pw>
 <20190111173132.GH6310@bombadil.infradead.org>
 <1547230356.6911.23.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1547230356.6911.23.camel@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, walken@google.com, David.Woodhouse@intel.com

On Fri, Jan 11, 2019 at 01:12:36PM -0500, Qian Cai wrote:
> On Fri, 2019-01-11 at 09:31 -0800, Matthew Wilcox wrote:
> > On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> > > Reported-by: Esme <esploit@protonmail.ch>
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > 
> > What change introduced this bug?��We need a Fixes: line so the stable
> > people know how far to backport this fix.
> 
> It looks like,
> 
> Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
> necessary)
> 
> where it no longer always paint the root as black.
> 
> Also, copying this fix for the original author and reviewer.
> 
> https://lore.kernel.org/lkml/20190111165145.23628-1-cai@lca.pw/

Great, thanks!  We have a test-suite (lib/rbtree_test.c); could you add
a test to it that will reproduce this bug without your patch applied?
