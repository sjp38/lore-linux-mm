Date: Fri, 15 Feb 2008 21:16:40 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 3/4] x86_64: Fold pda into per cpu area
Message-ID: <20080215201640.GA6200@elte.hu>
References: <20080201191414.961558000@sgi.com> <20080201191415.450555000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201191415.450555000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

>  include/asm-generic/vmlinux.lds.h |    2 +
>  include/linux/percpu.h            |    9 ++++-

couldnt these two generic bits be done separately (perhaps a preparatory 
but otherwise NOP patch pushed upstream straight away) to make 
subsequent patches only touch x86 architecture files?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
