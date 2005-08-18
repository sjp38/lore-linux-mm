Date: Wed, 17 Aug 2005 19:48:22 -0700 (PDT)
Message-Id: <20050817.194822.92757361.davem@davemloft.net>
Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050817173818.098462b5.akpm@osdl.org>
References: <20050810200943.809832000@jumble.boston.redhat.com>
	<20050810.133125.08323684.davem@davemloft.net>
	<20050817173818.098462b5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Date: Wed, 17 Aug 2005 17:38:18 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I'm prety sure we fixed that somehow.  But I forget how.

I wish you could remember :-)  I honestly don't think we did.
The DEFINE_PER_CPU() definition still looks the same, and the
way the .data.percpu section is layed out in the vmlinux.lds.S
is still the same as well.

The places which are not handled currently are in not-often-used areas
such as IPVS, some S390 drivers, and some other platform specific
code (likely platforms where the gcc problem in question never
existed).

I do note two important spots where the initialization is not
present, the loopback driver statistics and the scsi_done_q.
Hmmm...

If we are handling it somehow, that would be nice to know for
certain, because we could thus remove all of the ugly
initializers.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
