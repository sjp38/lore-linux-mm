Date: Fri, 15 Feb 2008 21:17:30 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] x86_64: Cleanup non-smp usage of cpu maps
Message-ID: <20080215201730.GA7496@elte.hu>
References: <20080201191414.961558000@sgi.com> <20080201191415.572662000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201191415.572662000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> Cleanup references to the early cpu maps for the non-SMP configuration 
> and remove some functions called for SMP configurations only.

thanks, applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
