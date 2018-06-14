Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3111F6B0003
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 17:27:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o7-v6so2519563pgc.23
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 14:27:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w20-v6si5199806pga.349.2018.06.14.14.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 14:27:11 -0700 (PDT)
Date: Thu, 14 Jun 2018 14:27:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update()
 preemption BUG
Message-Id: <20180614142710.8eafb333f6060dc19334ae46@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1806132205420.1596@nanos.tec.linutronix.de>
References: <20180504104451.20278-1-bigeasy@linutronix.de>
	<513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
	<20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org>
	<20180509223539.43aznhri72ephluc@linutronix.de>
	<524ecef9-e513-fec4-1178-ac1a87452e57@suse.cz>
	<alpine.DEB.2.21.1806132205420.1596@nanos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 13 Jun 2018 23:46:45 +0200 (CEST) Thomas Gleixner <tglx@linutronix.de> wrote:

> Can we please revert that master piece of duct tape engineering and wait
> for someone to actually trigger the warning again?

OK.
