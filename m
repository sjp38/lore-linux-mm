Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7ACD6B027B
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:48:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 31-v6so10553847plf.19
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:48:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3-v6si18163846pff.154.2018.07.02.13.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:48:49 -0700 (PDT)
Date: Mon, 2 Jul 2018 13:48:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-Id: <20180702134845.c4f536dead5374b443e24270@linux-foundation.org>
In-Reply-To: <20180702140502.GZ19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
	<1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
	<20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
	<084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
	<20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
	<20180702140502.GZ19043@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, 2 Jul 2018 16:05:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 29-06-18 20:15:47, Andrew Morton wrote:
> [...]
> > Would one of your earlier designs have addressed all usecases?  I
> > expect the dumb unmap-a-little-bit-at-a-time approach would have?
> 
> It has been already pointed out that this will not work.

I said "one of".  There were others.

> You simply
> cannot drop the mmap_sem during unmap because another thread could
> change the address space under your feet. So you need some form of
> VM_DEAD and handle concurrent and conflicting address space operations.

Unclear that this is a problem.  If a thread does an unmap of a range
of virtual address space, there's no guarantee that upon return some
other thread has not already mapped new stuff into that address range. 
So what's changed?
