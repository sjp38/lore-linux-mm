From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
Date: Fri, 18 Jan 2008 21:58:18 +0100
References: <20080118183011.354965000@sgi.com> <20080118204845.GD3079@elte.hu> <4791122E.8070205@sgi.com>
In-Reply-To: <4791122E.8070205@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801182158.18822.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Ingo Oeser <ioe-lkml@rameria.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> How big is the stack during early startup?

THREAD_ORDER (runs on init_stack's stack)

early init stack could be increased in theory with some effort,
but since that is all single threaded anyways just a few strategic
static __initdata's should be simple enough.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
