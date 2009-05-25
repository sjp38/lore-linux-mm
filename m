Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA216B005A
	for <linux-mm@kvack.org>; Mon, 25 May 2009 06:27:50 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
Date: Mon, 25 May 2009 15:37:34 +0930
References: <1242805059-18338-1-git-send-email-tj@kernel.org> <1242805059-18338-4-git-send-email-tj@kernel.org>
In-Reply-To: <1242805059-18338-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905251537.35981.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, x86@kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, linux@arm.linux.org.uk, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, jesper.nilsson@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, tony.luck@intel.com, takata@linux-m32r.org, geert@linux-m68k.org, monstr@monstr.eu, ralf@linux-mips.org, kyle@mcmartin.ca, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, chris@zankel.net, Jens Axboe <jens.axboe@oracle.com>, Dave Jones <davej@redhat.com>, Jeremy Fitzhardinge <jeremy@xensource.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 May 2009 05:07:35 pm Tejun Heo wrote:
> Percpu variable definition is about to be updated such that
>
> * percpu symbols must be unique even the static ones
>
> * in-function static definition is not allowed

That spluttering noise is be choking on the title of this patch :)

Making these pseudo statics is in no way a cleanup.  How about we just
say "they can't be static" and do something like:

/* Sorry, can't be static: that breaks archs which need these weak. */
#define DEFINE_PER_CPU(type, var) \
	extern typeof(type) var; DEFINE_PER_CPU_SECTION(type, name, "")

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
