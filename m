Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D3D706B0070
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:33:15 -0500 (EST)
Date: Mon, 10 Dec 2012 19:33:10 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org> <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org> <20121210180141.GK1009@suse.de>
In-Reply-To: <20121210180141.GK1009@suse.de>
Message-ID: <50C62AE6.3030000@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: kswapd craziness in 3.7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 10.12.2012 19:01, Mel Gorman wrote:
> In this last-minute disaster, I'm not thinking properly at all any more. The
> shrink slab disabling should have happened before the loop_again but even
> then it's wrong because it's just covering over the problem.
>
> The way order and testorder interact with how balanced is calculated means
> that we potentially call shrink_slab() multiple times and that thing is
> global in nature and basically uncontrolled. You could argue that we should
> only call shrink_slab() if order-0 watermarks are not met but that will
> not necessarily prevent kswapd reclaiming too much. It keeps going back
> to balance_pgdat needing its list of requirements drawn up and receive
> some major surgery and we're not going to do that as a quick hack.
>

I was about to apply the patch that you sent, and reboot the server, but 
it seems there's no point because the patch is flawed?

Anyway, if and when you have a proper one, I'll be glad to test it for 
you and report results.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
