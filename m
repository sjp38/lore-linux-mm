Message-ID: <44E3F570.2020608@google.com>
Date: Wed, 16 Aug 2006 21:49:52 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
References: <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <20060809.165431.118952392.davem@davemloft.net> <1155189988.12225.100.camel@twins> <44DF888F.1010601@google.com> <20060814051323.GA1335@2ka.mipt.ru> <1155537943.5696.118.camel@twins> <20060814065454.GA6356@2ka.mipt.ru>
In-Reply-To: <20060814065454.GA6356@2ka.mipt.ru>
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov wrote:
> On Mon, Aug 14, 2006 at 08:45:43AM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
>>>Just pure openssh for control connection (admin should be able to
>>>login).
>>
>>These periods of degenerated functionality should be short and
>>infrequent albeit critical for machine recovery. Would you rather have a
>>slower ssh login (the machine will recover) or drive/fly to Zanzibar to
>>physically reboot the machine?
> 
> It will not work, since you can not mark openssh sockets as those which
> are able to get memory from reserved pool. So admin unable to check the
> system status and make anything to turn system's life on.

This is incorrect, please see my previous email.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
