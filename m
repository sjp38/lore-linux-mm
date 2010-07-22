Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B02D6B02A5
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 06:55:27 -0400 (EDT)
Date: Thu, 22 Jul 2010 11:55:18 +0100
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100722105518.GJ10930@sirena.org.uk>
References: <000001cb296f$6eba8fa0$4c2faee0$%szyprowski@samsung.com> <20100722183432U.fujita.tomonori@lab.ntt.co.jp> <op.vf8oa80k7p4s8u@pikus> <20100722191658V.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722191658V.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: m.nazarewicz@samsung.com, m.szyprowski@samsung.com, corbet@lwn.net, linux-mm@kvack.org, p.osciak@samsung.com, xiaolin.zhang@intel.com, hvaibhav@ti.com, robert.fekete@stericsson.com, marcus.xm.lorentzon@stericsson.com, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 07:17:42PM +0900, FUJITA Tomonori wrote:

> And adjusting drivers in embedded systems is necessary anyway.

Actually for embedded systems we make strong efforts to ensure that
drivers do not need tuning per system and that where this is unavoidable
we separate the configuration from the driver itself (using either a
driver specific interface or a subsystem one depending on the
genericness) so that the driver does not need modifying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
