Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4C0F6B025E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 17:59:18 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id q18so10815969igr.2
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 14:59:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a67si8388452pfj.158.2016.06.10.14.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 14:59:17 -0700 (PDT)
Date: Fri, 10 Jun 2016 14:59:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmots-2016-06-09-16-49] sleeping function called from
 slab_alloc()
Message-Id: <20160610145916.d071635d6462e4d837959e45@linux-foundation.org>
In-Reply-To: <477de582bf99ba64be662a42bf023b54@suse.de>
References: <20160610061139.GA374@swordfish>
	<20160610095048.GA655@swordfish>
	<477de582bf99ba64be662a42bf023b54@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko <mhocko@suse.de>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel-owner@vger.kernel.org

On Fri, 10 Jun 2016 11:55:54 +0200 mhocko <mhocko@suse.de> wrote:

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

Doesn't this simply mean that Sergey's workload will blurt a pr_warn()
rather than a BUG()?  That still needs fixing.  Confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
