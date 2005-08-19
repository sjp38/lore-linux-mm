Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20050819001030.52ec1364.akpm@osdl.org>
References: <20050817173818.098462b5.akpm@osdl.org>
	 <20050817.194822.92757361.davem@davemloft.net>
	 <20050817210532.54ace193.akpm@osdl.org>
	 <20050817.214845.120320066.davem@davemloft.net>
	 <1124435027.23757.0.camel@localhost.localdomain>
	 <20050819001030.52ec1364.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 19 Aug 2005 17:27:06 +1000
Message-Id: <1124436426.23757.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: davem@davemloft.net, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-08-19 at 00:10 -0700, Andrew Morton wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > I believe we just ignored sparc64.  That usually works for solving these
> > kind of bugs. 8)
> 
> heh.  iirc, it was demonstrable on x86 also.

No.  gcc-2.95 on Sparc64 put uninititialized vars into the bss, ignoring
the __attribute__((section(".data.percpu"))) directive.  x86 certainly
doesn't have this, I just tested it w/2.95.

Really, it's Sparc64 + gcc-2.95.  Send an urgent telegram to the user
telling them to upgrade.

Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
