Date: Wed, 16 Jul 2008 18:28:00 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] - Fix kernel_physical_mapping_init() for large x86
	systems
Message-ID: <20080716162800.GB19566@elte.hu>
References: <20080716161159.GA23870@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080716161159.GA23870@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Fix bug in kernel_physical_mapping_init() that causes kernel page 
> table to be built incorrectly for systems with greater than 512GB of 
> memory.
> 
> Signed-off-by: Jack Steiner <steiner@sgi.com>

applied to tip/x86/urgent - thanks Jack.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
