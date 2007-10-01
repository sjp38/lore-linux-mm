Date: Sun, 30 Sep 2007 17:27:03 -0700 (PDT)
Message-Id: <20070930.172703.79041329.davem@davemloft.net>
Subject: Re: [ANNOUNCE] ebizzy 0.2 released
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070823010626.GC11402@rainbow>
References: <20070823010626.GC11402@rainbow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Valerie Henson <val@nmt.edu>
Date: Wed, 22 Aug 2007 19:06:26 -0600
Return-Path: <owner-linux-mm@kvack.org>
To: val@nmt.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rrbranco@br.ibm.com, twichell@us.ibm.com, ycai@us.ibm.com
List-ID: <linux-mm.kvack.org>

> ebizzy is designed to generate a workload resembling common web
> application server workloads.

I downloaded this only to be basically disappointed.

Any program which claims to generate workloads "resembling common web
application server workloads", and yet does zero network activity and
absolutely nothing with sockets is so far disconnected from reality
that I truly question how useful it really is even in the context it
was designed for.

Please describe this program differently, "a threaded cpu eater", "a
threaded memory scanner", "a threaded hash lookup", or something
suitably matching what it really does.

I'm sure there are at least 10 or even more programs in LTP that one
could run under "time" and get the same exact functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
