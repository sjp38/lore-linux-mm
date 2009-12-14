Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BC1FC6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 03:49:39 -0500 (EST)
Received: by yxe10 with SMTP id 10so2572449yxe.12
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 00:49:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0912140646550.12657@sebohet.brgvxre.pu>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com>
	 <20091113181557.GM29804@csn.ul.ie>
	 <2f11576a0911131033w4a9e6042k3349f0be290a167e@mail.gmail.com>
	 <20091113200357.GO29804@csn.ul.ie>
	 <alpine.DEB.2.00.0911261542500.21450@sebohet.brgvxre.pu>
	 <alpine.DEB.2.00.0911290834470.20857@sebohet.brgvxre.pu>
	 <20091202113241.GC1457@csn.ul.ie>
	 <alpine.DEB.2.00.0912022210220.30023@sebohet.brgvxre.pu>
	 <4e5e476b0912031226i5b0e6cf9hdfd5519182ccdefa@mail.gmail.com>
	 <alpine.DEB.2.00.0912140646550.12657@sebohet.brgvxre.pu>
Date: Mon, 14 Dec 2009 09:49:32 +0100
Message-ID: <4e5e476b0912140049x29d2905epf1a21bfdbd1709a6@mail.gmail.com>
Subject: Re: still getting allocation failures (was Re: [PATCH] vmscan: Stop
	kswapd waiting on congestion when the min watermark is not being met V2)
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Tobi,
On Mon, Dec 14, 2009 at 6:59 AM, Tobias Oetiker <tobi@oetiker.ch> wrote:
> Hi Corrado,
>
> Dec 3 Corrado Zoccolo wrote:
>
>> Hi Tobias,
>> does the patch in http://lkml.org/lkml/2009/11/30/301 help with your
>> high order allocation problems?
>> It seems that you have lot of memory, but high order pages do not show u=
p.
>> The patch should make them more likely to appear.
>> On my machine (that has much less ram than yours), with the patch, I
>> always have order-10 pages available.
>
> I have tried it and ... it does not work, the =C2=A0page allocation
> failure still shows. BUT while testing it on two machines I found that it
> only shows on on machine. The workload on the two machines is
> similar (they both run virtualbox) and also the available memory.

Where those both failing before the patch?
Did the order of failure change?

> Could it be caused by a hardware driver ?
It should be something that is taking more time to release pages, but
I don't know what can it be. What happens if you drop the caches when
you are getting failures? Does the failure rate drops as if you had
just rebooted?
Can you log at regular intervals the content of /proc/buddyinfo, and
try  correlating when the number of pages of the requested order are
becoming scarce with some other event?

Thanks,
Corrado
>
> cheers
> tobi
>
> --
> Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
> http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900
>



--=20
__________________________________________________________________________

dott. Corrado Zoccolo                          mailto:czoccolo@gmail.com
PhD - Department of Computer Science - University of Pisa, Italy
--------------------------------------------------------------------------
The self-confidence of a warrior is not the self-confidence of the average
man. The average man seeks certainty in the eyes of the onlooker and calls
that self-confidence. The warrior seeks impeccability in his own eyes and
calls that humbleness.
                               Tales of Power - C. Castaneda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
