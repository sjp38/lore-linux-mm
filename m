Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A14BB6B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 17:12:39 -0500 (EST)
Date: Wed, 27 Jan 2010 14:12:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Flush dcache before writing into page to avoid alias
Message-Id: <20100127141208.dd8244a7.akpm@linux-foundation.org>
In-Reply-To: <20100127215959.GC15325@Chamillionaire.breakpoint.cc>
References: <979dd0561001202107v4ddc1eb7xa59a7c16c452f7a2@mail.gmail.com>
	<20100125133308.GA26799@desktop>
	<20100125115814.156d401d.akpm@linux-foundation.org>
	<20100125200004.GF22481@n2100.arm.linux.org.uk>
	<20100127215959.GC15325@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, anfei <anfei.zhou@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jamie Lokier <jamie@shareable.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010 22:59:59 +0100
Sebastian Andrzej Siewior <sebastian@breakpoint.cc> wrote:

> I just wanted to query what the status of this patch is. This patch
> seems to fix a real bug which causes a test suite to fail on ARM [0].
> The test suite passes on my VIVT ARM with this patch.
> 
> [0] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=524003

I have it queued for 2.6.33, backportable to 2.6.32.x, assuming that
nobody sees any issues with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
