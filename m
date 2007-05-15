Date: Tue, 15 May 2007 10:16:09 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <1179218576.25205.1.camel@rousalka.dyndns.org>
Message-ID: <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
 <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="29444707-1445859050-1179219542=:6896"
Content-ID: <Pine.LNX.4.64.0705151015300.6896@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicolas Mailhot <nicolas.mailhot@laposte.net>
Cc: Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--29444707-1445859050-1179219542=:6896
Content-Type: TEXT/PLAIN; CHARSET=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0705151015301.6896@skynet.skynet.ie>

On Tue, 15 May 2007, Nicolas Mailhot wrote:

> Le lundi 14 mai 2007 =C3=A0 19:24 +0100, Mel Gorman a =C3=A9crit :
>> On (14/05/07 11:13), Christoph Lameter didst pronounce:
>>> I think the slub fragment may have to be this way? This calls
>>> raise_kswapd_order on each kmem_cache_create with the order of the cach=
e
>>> that was created thus insuring that the min_order is correctly.
>>>
>>> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>>>
>>
>> Good plan. Revised patch as follows;
>
> Kernel with this patch and the other one survives testing. I'll stop
> heavy testing now and consider the issue closed.
>

That is good news, thanks for the report.

> Thanks for looking at my bug report.
>

Thank you very much for your testing. I know it was a lot to ask to tie a=
=20
machine up for a few days.

--=20
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
--29444707-1445859050-1179219542=:6896--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
