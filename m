Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 609256B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:03:41 -0400 (EDT)
Date: Wed, 14 Aug 2013 14:03:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8] mm: make lru_add_drain_all() selective
Message-Id: <20130814140339.4489fd3efc7de3d0a5b21c4e@linux-foundation.org>
In-Reply-To: <20130814205029.GN28628@htj.dyndns.org>
References: <20130814200748.GI28628@htj.dyndns.org>
	<201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
	<20130814134430.50cb8d609643620b00ab3705@linux-foundation.org>
	<20130814205029.GN28628@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Wed, 14 Aug 2013 16:50:29 -0400 Tejun Heo <tj@kernel.org> wrote:

> > > +	for_each_cpu(cpu, &has_work)
> > 
> > for_each_online_cpu()?
> 
> That would lead to flushing work items which aren't used and may not
> have been initialized yet, no?

doh, I confused for_each_cpu with for_each_possible_cpu.  Dumb name.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
