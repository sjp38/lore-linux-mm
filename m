Date: Fri, 25 Jan 2008 01:25:43 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/3] percpu: Optimize percpu accesses
Message-ID: <20080125002543.GA931@elte.hu>
References: <20080123044924.508382000@sgi.com> <20080124224613.GA24855@elte.hu> <47992AA8.6040804@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47992AA8.6040804@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> > tried it on x86.git and 1/3 did not build and 2/3 causes a boot hang 
> > with the attached .config.
> 
> The build error was fixed with the note I sent to you yesterday with a 
> "fixup" patch for changes in -mm but not in x86.git (attached).

no, that build error was in patch #2, and your later patch made it 
possible for me to bisect down to that point. #1 failed differently. 
(and not in module.c - dont remember the details - let me know if you 
cannot reproduce - the hang in #2 was the more significant bug.) The 
hang gave no messages on the earlyprintk serial console.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
