Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EFE536B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:28:45 -0400 (EDT)
Received: by qwa26 with SMTP id 26so972133qwa.14
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 05:28:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110609113505.GR5247@suse.de>
References: <1307606573-24704-1-git-send-email-mgorman@suse.de>
 <1307606573-24704-11-git-send-email-mgorman@suse.de> <BANLkTimUE9yb-DegdUk0BbbOGWoUhEBrqw@mail.gmail.com>
 <20110609113505.GR5247@suse.de>
From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Date: Thu, 9 Jun 2011 14:28:24 +0200
Message-ID: <BANLkTi=8jx8B8fR_+Z76UoTe_jhG9G-Tyw@mail.gmail.com>
Subject: Re: [PATCH 10/14] netvm: Set PF_MEMALLOC as appropriate during SKB processing
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

2011/6/9 Mel Gorman <mgorman@suse.de>:
> On Thu, Jun 09, 2011 at 12:21:31PM +0200, Micha? Miros?aw wrote:
>> 2011/6/9 Mel Gorman <mgorman@suse.de>:
>> [...]
>> > +/*
>> > + * Limit which protocols can use the PFMEMALLOC reserves to those tha=
t are
>> > + * expected to be used for communication with swap.
>> > + */
>> > +static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 switch (skb->protocol) {
>> > + =C2=A0 =C2=A0 =C2=A0 case __constant_htons(ETH_P_ARP):
>> > + =C2=A0 =C2=A0 =C2=A0 case __constant_htons(ETH_P_IP):
>> > + =C2=A0 =C2=A0 =C2=A0 case __constant_htons(ETH_P_IPV6):
>> > + =C2=A0 =C2=A0 =C2=A0 case __constant_htons(ETH_P_8021Q):
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
>> > + =C2=A0 =C2=A0 =C2=A0 default:
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > +}
>>
>> This is not needed and wrong. Whatever list there will be, it's going
>> to always miss some obscure setup (or not that obscure, like
>> ATAoverEthernet).
>>
>
> NBD is updated in the series to set the socket information
> appropriately but the same cannot be said of AoE. The necessary
> changes have been made IPv4 and IPv6 to handle pfmemalloc sockets
> but the same cannot be necessarily said for the other protocols. Yes,
> the check could be removed but leaving it there makes a clear statement
> on what scenario can be reasonably expected to work.

Ok. Then the comment before skb_pfmemalloc_protocol() is misleading.
It should say that this is a list of protocols which implement the
required special handling of PFMEMALLOC skbs.

Best Regards,
Micha=C5=82 Miros=C5=82aw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
