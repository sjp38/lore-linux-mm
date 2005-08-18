Date: Wed, 17 Aug 2005 21:05:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement
Message-Id: <20050817210532.54ace193.akpm@osdl.org>
In-Reply-To: <20050817.194822.92757361.davem@davemloft.net>
References: <20050810200943.809832000@jumble.boston.redhat.com>
	<20050810.133125.08323684.davem@davemloft.net>
	<20050817173818.098462b5.akpm@osdl.org>
	<20050817.194822.92757361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@davemloft.net> wrote:
>
> From: Andrew Morton <akpm@osdl.org>
> Date: Wed, 17 Aug 2005 17:38:18 -0700
> 
> > I'm prety sure we fixed that somehow.  But I forget how.
> 
> I wish you could remember :-)  I honestly don't think we did.
> The DEFINE_PER_CPU() definition still looks the same, and the
> way the .data.percpu section is layed out in the vmlinux.lds.S
> is still the same as well.

Argh, can't remember, can't find it with archive grep.  I just have a
mental note that it got fixed somehow.  Perhaps by uprevving the compiler
version?  We certainly have a ton of uninitialised DEFINE_PER_CPUs in there
nowadays and people's kernels aren't crashing.

Rusty, do you recall if/how we fixed the
DEFINE_PER_CPU-needs-explicit-initialisation thing?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
