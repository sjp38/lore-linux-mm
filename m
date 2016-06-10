Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0643F6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 05:58:19 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id y7so36146071obt.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:58:19 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q2si12531868pfq.114.2016.06.10.02.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 02:58:18 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 62so4837100pfd.3
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:58:14 -0700 (PDT)
Date: Fri, 10 Jun 2016 18:58:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [mmots-2016-06-09-16-49] sleeping function called from
 slab_alloc()
Message-ID: <20160610095808.GB655@swordfish>
References: <20160610061139.GA374@swordfish>
 <20160610095048.GA655@swordfish>
 <477de582bf99ba64be662a42bf023b54@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <477de582bf99ba64be662a42bf023b54@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko <mhocko@suse.de>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel-owner@vger.kernel.org

On (06/10/16 11:55), mhocko wrote:
> On 2016-06-10 11:50, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > forked from http://marc.info/?l=linux-mm&m=146553910928716&w=2
> > 
> > new_slab()->BUG->die()->exit_signals() can be called from atomic
> > context: local IRQs disabled in slab_alloc().
> 
> I have sent a patch to drop the BUG() from that path today. It
> is just too aggressive way to react to a non-critical bug.
> See
> http://lkml.kernel.org/r/1465548200-11384-2-git-send-email-mhocko@kernel.org

ah, ok. didn't see that one.
thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
