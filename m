Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5E66B0062
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 22:29:02 -0400 (EDT)
Message-ID: <4A3854BF.4000300@kernel.org>
Date: Wed, 17 Jun 2009 11:28:15 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
References: <1243846708-805-1-git-send-email-tj@kernel.org> <1243846708-805-4-git-send-email-tj@kernel.org> <20090601.024006.98975069.davem@davemloft.net> <4A23BD20.5030500@kernel.org> <1243919336.5308.32.camel@pasglop> <4A289E3A.30000@kernel.org> <20090611104550.GQ20504@axis.com>
In-Reply-To: <20090611104550.GQ20504@axis.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Nilsson <Jesper.Nilsson@axis.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, "JBeulich@novell.com" <JBeulich@novell.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "rth@twiddle.net" <rth@twiddle.net>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "hskinnemoen@atmel.com" <hskinnemoen@atmel.com>, "cooloney@kernel.org" <cooloney@kernel.org>, Mikael Starvik <mikael.starvik@axis.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "ysato@users.sourceforge.jp" <ysato@users.sourceforge.jp>, "tony.luck@intel.com" <tony.luck@intel.com>, "takata@linux-m32r.org" <takata@linux-m32r.org>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "ralf@linux-mips.org" <ralf@linux-mips.org>, "kyle@mcmartin.ca" <kyle@mcmartin.ca>, "paulus@samba.org" <paulus@samba.org>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "jdike@addtoit.com" <jdike@addtoit.com>, "chris@zankel.net" <chris@zankel.net>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>, "davej@redhat.com" <davej@redhat.com>, "jeremy@xensource.com" <jeremy@xensource.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

Jesper Nilsson wrote:
> I've talked with Mikael, and we both agreed that this was probably
> a legacy from earlier versions, and the volatile is no longer needed.
> 
> Confirmed by booting and running some video-streaming on an ARTPEC-3
> (CRISv32) board.
> 
> You can take the following patch as a pre-requisite, or go the way of
> the original patch.
> 
> From: Jesper Nilsson <jesper.nilsson@axis.com>
> Subject: [PATCH] CRIS: Change DEFINE_PER_CPU of current_pgd to be non volatile.
> 
> The DEFINE_PER_CPU of current_pgd was on CRIS defined using volatile,
> which is not needed. Remove volatile.
> 
> Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>

Super.  Included in the series.

Thanks a lot.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
