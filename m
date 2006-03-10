Received: by wproxy.gmail.com with SMTP id 57so127960wri
        for <linux-mm@kvack.org>; Fri, 10 Mar 2006 05:19:55 -0800 (PST)
Message-ID: <aec7e5c30603100519l5a68aec3ub838ac69a734a46b@mail.gmail.com>
Date: Fri, 10 Mar 2006 14:19:55 +0100
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
In-Reply-To: <1141977139.2876.15.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <1141977139.2876.15.camel@laptopd505.fenrus.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/10/06, Arjan van de Ven <arjan@infradead.org> wrote:
> > Apply on top of 2.6.16-rc5.
> >
> > Comments?
>
>
> my big worry with a split LRU is: how do you keep fairness and balance
> between those LRUs? This is one of the things that made the 2.4 VM suck
> really badly, so I really wouldn't want this bad...

Yeah, I agree this is important. I think linux-2.4 tried to keep the
LRU list lengths in a certain way (maybe 2/3 of all pages active, 1/3
inactive). In 2.6 there is no such thing, instead the number of pages
scanned is related to the current scanning priority.

My current code just extends this idea which basically means that
there is currently no relation between how many pages that sit in each
LRU. The LRU with the largest amount of pages will be shrunk/rotated
first. And on top of that is the guarantee logic and the
reclaim_mapped threshold, ie the unmapped LRU will be shrunk first by
default.

The current balancing code plays around with nr_scan_active and
nr_scan_inactive, but I'm not entirely sure why that logic is there.
If anyone can explain the reason behind that code I'd be happy to hear
it.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
