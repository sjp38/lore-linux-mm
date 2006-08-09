Message-ID: <44D93BEE.4000001@google.com>
Date: Tue, 08 Aug 2006 18:35:42 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
References: <20060808193325.1396.58813.sendpatchset@lappy>	<20060808193345.1396.16773.sendpatchset@lappy> <20060808.151020.94555184.davem@davemloft.net>
In-Reply-To: <20060808.151020.94555184.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

David Miller wrote:
> I think the new atomic operation that will seemingly occur on every
> device SKB free is unacceptable.

Alternate suggestion?

> You also cannot modify netdev->flags in the lockless manner in which
> you do, it must be done with the appropriate locking, such as holding
> the RTNL semaphore.

Thanks for the catch.

Regards,

Daniel



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
