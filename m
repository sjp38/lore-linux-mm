Date: Sat, 12 Aug 2006 17:46:51 -0700 (PDT)
Message-Id: <20060812.174651.113732891.davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
From: David Miller <davem@davemloft.net>
In-Reply-To: <1155377887.13508.27.camel@lappy>
References: <1155374390.13508.15.camel@lappy>
	<20060812093706.GA13554@2ka.mipt.ru>
	<1155377887.13508.27.camel@lappy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Sat, 12 Aug 2006 12:18:07 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: johnpol@2ka.mipt.ru, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

> 65535 sockets * 128 packets * 16384 bytes/packet = 
> 1^16 * 1^7 * 1^14 = 1^(16+7+14) = 1^37 = 128G of memory per IP
> 
> And systems with a lot of IP numbers are not unthinkable.

TCP restricts the amount of global memory that may be consumed
by all TCP sockets via the tcp_mem[] sysctl.

Otherwise several forms of DoS attacks would be possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
