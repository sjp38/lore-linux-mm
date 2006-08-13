Date: Sat, 12 Aug 2006 17:46:07 -0700 (PDT)
Message-Id: <20060812.174607.44371641.davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060812093706.GA13554@2ka.mipt.ru>
References: <20060812084713.GA29523@2ka.mipt.ru>
	<1155374390.13508.15.camel@lappy>
	<20060812093706.GA13554@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 12 Aug 2006 13:37:06 +0400
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: a.p.zijlstra@chello.nl, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

> Does it? I though it is possible to only have 64k of working sockets per
> device in TCP.

Where does this limit come from?

You think there is something magic about 64K local ports,
but if remote IP addresses in the TCP socket IDs are all
different, number of possible TCP sockets is only limited
by "number of client IPs * 64K" and ram :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
