Date: Fri, 18 Jan 2008 21:39:29 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/7] percpu: Per cpu code simplification fixup
Message-ID: <20080118203928.GB3079@elte.hu>
References: <20080118182953.748071000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080118182953.748071000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> This patchset simplifies the code that arches need to maintain to 
> support per cpu functionality. Most of the code is moved into arch 
> independent code. Only a minimal set of definitions is kept for each 
> arch.
> 
> The patch also unifies the x86 arch so that there is only a single 
> asm-x86/percpu.h
> 
> Based on: 2.6.24-rc8-mm1

just to make sure i got it right: due to the multi-arch scope of this 
patchset, this is for -mm, right?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
