Date: Tue, 22 Apr 2008 10:07:47 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 2/2]: introduce fast_gup
Message-ID: <20080422080747.GA18587@elte.hu>
References: <20080328025455.GA8083@wotan.suse.de> <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins> <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org> <480C81C4.8030200@qumranet.com> <1208781013.7115.173.camel@twins> <480C9619.2050201@qumranet.com> <1208788547.7115.204.camel@twins> <20080422032319.GB21993@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422032319.GB21993@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Avi Kivity <avi@qumranet.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> Linus's loop I will use for PAE. I'd love to know whether the hardware 
> walker actually does an atomic 64-bit load or not, though.

all x86 natural accesses (done by instructions) are MESI atomic as long 
as they lie on a natural word boundary. (which they do in the PTE case)

while the hardware walker is not an instruction, it would be highly 
unusal (and i'd claim, inherently broken) for the hardware walker to 
fetch a 64-bit pte value via two 32-bit accesses from two different 
versions of the same cacheline.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
