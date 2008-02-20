Date: Wed, 20 Feb 2008 10:15:29 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] x86: Optimize percpu accesses v3
Message-ID: <20080220091529.GD31424@elte.hu>
References: <20080219203335.866324000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219203335.866324000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> This patchset is the x86-specific part split from the generic part of 
> the zero-based patchset.

thanks Mike, applied them to x86.git. Do these depend on the generic 
bits? (for now we'll keep these in -testing, so that they do not reach 
-mm)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
