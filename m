Date: Fri, 21 Mar 2008 15:24:33 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] - Increase max physical memory size of x86_64
Message-ID: <20080321142433.GA31719@elte.hu>
References: <20080321133157.GA10911@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080321133157.GA10911@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: ak@suse.de, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Increase the maximum physical address size of x86_64 system to 
> 44-bits. This is in preparation for future chips that support larger 
> physical memory sizes.

thanks, applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
