Date: Tue, 08 Aug 2006 22:56:53 -0700 (PDT)
Message-Id: <20060808.225653.85409729.davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
From: David Miller <davem@davemloft.net>
In-Reply-To: <44D97822.5010007@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060809054648.GD17446@2ka.mipt.ru>
	<44D97822.5010007@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 22:52:34 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: phillips@google.com
Cc: johnpol@2ka.mipt.ru, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Agreed.  But probably more intrusive than davem would be happy with
> at this point.

I'm much more happy with Evgeniy's network tree allocator, which has a
real design and well thought our long term consequences, than your
work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
