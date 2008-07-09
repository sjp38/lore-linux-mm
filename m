Date: Wed, 9 Jul 2008 08:02:04 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/2] - Map UV chipset space - UV support
Message-ID: <20080709060204.GD9760@elte.hu>
References: <20080701194538.GA28410@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080701194538.GA28410@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Create page table entries to map the SGI UV chipset GRU. local MMR & 
> global MMR ranges.

applied to tip/x86/core, thanks Jack.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
