Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42DCC6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 15:40:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p91-v6so1695389plb.12
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:40:23 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z4-v6si3982378pgv.621.2018.06.27.12.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 12:40:21 -0700 (PDT)
Date: Wed, 27 Jun 2018 15:40:18 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update()
 preemption BUG
Message-ID: <20180627194018.6jwkta4eagxiixix@home.goodmis.org>
References: <20180504104451.20278-1-bigeasy@linutronix.de>
 <513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
 <20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org>
 <20180509223539.43aznhri72ephluc@linutronix.de>
 <524ecef9-e513-fec4-1178-ac1a87452e57@suse.cz>
 <alpine.DEB.2.21.1806132205420.1596@nanos.tec.linutronix.de>
 <20180614142710.8eafb333f6060dc19334ae46@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180614142710.8eafb333f6060dc19334ae46@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org

On Thu, Jun 14, 2018 at 02:27:10PM -0700, Andrew Morton wrote:
> On Wed, 13 Jun 2018 23:46:45 +0200 (CEST) Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > Can we please revert that master piece of duct tape engineering and wait
> > for someone to actually trigger the warning again?
> 
> OK.

And while we're at it, can we revert it from stable as well. As this is just
an overly aggressive pulling anything that looks like a fix into stable.

-- Steve
