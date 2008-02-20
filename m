Date: Wed, 20 Feb 2008 10:14:34 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] percpu: Optimize percpu accesses v3
Message-ID: <20080220091434.GC31424@elte.hu>
References: <20080219203226.746641000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219203226.746641000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> This is the generic (non-x86) changes for zero-based per cpu 
> variables.

thanks Mike. I've put this into the -testing branch of x86.git. (so that 
we can see and test the impact of these patches, but they wont leak into 
-mm)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
