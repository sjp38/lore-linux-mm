Date: Wed, 17 Aug 2005 21:48:45 -0700 (PDT)
Message-Id: <20050817.214845.120320066.davem@davemloft.net>
Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050817210532.54ace193.akpm@osdl.org>
References: <20050817173818.098462b5.akpm@osdl.org>
	<20050817.194822.92757361.davem@davemloft.net>
	<20050817210532.54ace193.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Date: Wed, 17 Aug 2005 21:05:32 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

> Perhaps by uprevving the compiler version?

Can't be, we definitely support gcc-2.95 and that compiler
definitely has the bug on sparc64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
