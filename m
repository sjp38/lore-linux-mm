Date: Wed, 30 Jan 2008 22:53:39 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 6/6] s390: Use generic percpu linux-2.6.git
Message-ID: <20080130215339.GC28242@elte.hu>
References: <20080130180940.022172000@sgi.com> <20080130180940.921597000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130180940.921597000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> Change s390 percpu.h to use asm-generic/percpu.h

do the s390 maintainer agree with this change (Acks please), and has it 
been tested on s390?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
