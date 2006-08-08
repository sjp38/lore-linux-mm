Date: Tue, 08 Aug 2006 15:10:20 -0700 (PDT)
Message-Id: <20060808.151020.94555184.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060808193345.1396.16773.sendpatchset@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060808193345.1396.16773.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

I think the new atomic operation that will seemingly occur on every
device SKB free is unacceptable.

You also cannot modify netdev->flags in the lockless manner in which
you do, it must be done with the appropriate locking, such as holding
the RTNL semaphore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
