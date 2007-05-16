Date: Wed, 16 May 2007 10:03:10 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <464AC00E.10704@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
 <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org>
 <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="29444707-1639998271-1179306096=:7139"
Content-ID: <Pine.LNX.4.64.0705161002170.7139@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--29444707-1639998271-1179306096=:7139
Content-Type: TEXT/PLAIN; CHARSET=X-UNKNOWN; FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0705161002171.7139@skynet.skynet.ie>

On Wed, 16 May 2007, Nick Piggin wrote:

> Mel Gorman wrote:
>> On Tue, 15 May 2007, Nicolas Mailhot wrote:
>>=20
>>> Le lundi 14 mai 2007 =E0 19:24 +0100, Mel Gorman a =E9crit :
>>>=20
>>>> On (14/05/07 11:13), Christoph Lameter didst pronounce:
>>>>=20
>>>>> I think the slub fragment may have to be this way? This calls
>>>>> raise_kswapd_order on each kmem_cache_create with the order of the ca=
che
>>>>> that was created thus insuring that the min_order is correctly.
>>>>>=20
>>>>> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>>>>>=20
>>>>=20
>>>> Good plan. Revised patch as follows;
>>>=20
>>>=20
>>> Kernel with this patch and the other one survives testing. I'll stop
>>> heavy testing now and consider the issue closed.
>>>=20
>>=20
>> That is good news, thanks for the report.
>>=20
>>> Thanks for looking at my bug report.
>>>=20
>>=20
>> Thank you very much for your testing. I know it was a lot to ask to tie =
a=20
>> machine up for a few days.
>
> Hmm, so we require higher order pages be kept free even if nothing is
> using them? That's not very nice :(
>

Not quite. We are already required to keep a minimum number of pages free=
=20
even though nothing is using them. The difference is that if it is known=20
high-order allocations are frequently required, the freed pages will be=20
contiguous. If no one calls raise_kswapd_order(), kswapd will continue=20
reclaiming at order-0. Arguably, e1000 should also be calling=20
raise_kswapd_order() when it is using jumbo frames.

--=20
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
--29444707-1639998271-1179306096=:7139--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
