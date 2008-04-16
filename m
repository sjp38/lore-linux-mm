Date: Wed, 16 Apr 2008 20:45:43 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] - Increase MAX_APICS for large configs
Message-ID: <20080416184543.GD3722@elte.hu>
References: <20080416163936.GA23099@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080416163936.GA23099@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Increase the maximum number of apics when running very large 
> configurations. This patch has no affect on most systems.
> 
> Signed-off-by: Jack Steiner <steiner@sgi.com>
> 
> I think this area of the code will be substantially changed when the 
> full x2apic patch is available. In the meantime, this seems like an 
> acceptible alternative. The patch has no effect on any 32-bit kernel. 
> It adds ~4k to the size of 64-bit kernels but only if NR_CPUS > 255.

ugly ... but well - applied. What's the static size cost of 64K APICs?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
