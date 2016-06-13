Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 169276B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:47:37 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so57530991lff.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:47:37 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ag2si5776576wjc.200.2016.06.13.03.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 03:47:35 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r5so13827391wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:47:35 -0700 (PDT)
Date: Mon, 13 Jun 2016 12:47:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mmots-2016-06-09-16-49] sleeping function called from
 slab_alloc()
Message-ID: <20160613104733.GA6518@dhcp22.suse.cz>
References: <20160610061139.GA374@swordfish>
 <20160610095048.GA655@swordfish>
 <477de582bf99ba64be662a42bf023b54@suse.de>
 <20160610145916.d071635d6462e4d837959e45@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160610145916.d071635d6462e4d837959e45@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel-owner@vger.kernel.org

On Fri 10-06-16 14:59:16, Andrew Morton wrote:
> On Fri, 10 Jun 2016 11:55:54 +0200 mhocko <mhocko@suse.de> wrote:
> 
> > On 2016-06-10 11:50, Sergey Senozhatsky wrote:
> > > Hello,
> > > 
> > > forked from http://marc.info/?l=linux-mm&m=146553910928716&w=2
> > > 
> > > new_slab()->BUG->die()->exit_signals() can be called from atomic
> > > context: local IRQs disabled in slab_alloc().
> > 
> > I have sent a patch to drop the BUG() from that path today. It
> > is just too aggressive way to react to a non-critical bug.
> > See 
> > http://lkml.kernel.org/r/1465548200-11384-2-git-send-email-mhocko@kernel.org
> 
> Doesn't this simply mean that Sergey's workload will blurt a pr_warn()
> rather than a BUG()?  That still needs fixing.  Confused.

Yes that should be fixed by
http://lkml.kernel.org/r/20160610074223.GC32285@dhcp22.suse.cz

which prevents from using a wrong GFP...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
