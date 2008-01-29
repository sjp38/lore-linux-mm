Date: Tue, 29 Jan 2008 12:13:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/3] percpu: Optimize percpu accesses
In-Reply-To: <479F85F9.3040104@sgi.com>
Message-ID: <Pine.LNX.4.64.0801291213190.25468@schroedinger.engr.sgi.com>
References: <20080123044924.508382000@sgi.com> <20080124224613.GA24855@elte.hu>
 <479F85F9.3040104@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Mike Travis wrote:

> Since the zero-based patch is changing the offset from one based on
> __per_cpu_start to zero, it's causing the function to access a
> different area.

Looks like we just need to set the offset used for 0 to 
__per_cpu_start during early boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
