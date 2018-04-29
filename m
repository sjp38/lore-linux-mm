Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Sun, 29 Apr 2018 19:51:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86: Mark up large pm4/5 constants with UL
Message-ID: <20180429165124.frht65qz6bqoklwd@kshutemo-mobl1>
References: <20180429114832.14552-1-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180429114832.14552-1-chris@chris-wilson.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 29, 2018 at 12:48:32PM +0100, Chris Wilson wrote:
> To silence sparse while maintaining compatibility with the assembly, use
> _UL which conditionally only appends the UL suffix for C code.

http://lkml.kernel.org/r/nycvar.YFH.7.76.1804121437350.28129@cbobk.fhfr.pm

-- 
 Kirill A. Shutemov
