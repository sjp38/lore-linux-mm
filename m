Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F033A6B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 05:55:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so34241053wme.2
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:55:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si13001897wje.150.2016.06.10.02.55.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 02:55:56 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Jun 2016 11:55:54 +0200
From: mhocko <mhocko@suse.de>
Subject: Re: [mmots-2016-06-09-16-49] sleeping function called from
 slab_alloc()
In-Reply-To: <20160610095048.GA655@swordfish>
References: <20160610061139.GA374@swordfish>
 <20160610095048.GA655@swordfish>
Message-ID: <477de582bf99ba64be662a42bf023b54@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel-owner@vger.kernel.org

On 2016-06-10 11:50, Sergey Senozhatsky wrote:
> Hello,
> 
> forked from http://marc.info/?l=linux-mm&m=146553910928716&w=2
> 
> new_slab()->BUG->die()->exit_signals() can be called from atomic
> context: local IRQs disabled in slab_alloc().

I have sent a patch to drop the BUG() from that path today. It
is just too aggressive way to react to a non-critical bug.
See 
http://lkml.kernel.org/r/1465548200-11384-2-git-send-email-mhocko@kernel.org
-- 
Michal Hocko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
