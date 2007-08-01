Date: Wed, 1 Aug 2007 07:25:14 +0200
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [ck] Re: SD still better than CFS for 3d ?
Message-ID: <20070801052513.GL3972@stusta.de>
References: <930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com> <20070729204716.GB1578@elte.hu> <930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com> <20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site> <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com> <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com> <20070730182959.GA29151@infradead.org> <adaps29sm62.fsf@cisco.com> <b21f8390707302007n2f21018crc6b7cd83666e0f3c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <b21f8390707302007n2f21018crc6b7cd83666e0f3c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Roland Dreier <rdreier@cisco.com>, Christoph Hellwig <hch@infradead.org>, Jacob Braun <jwbraun@gmail.com>, kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 31, 2007 at 01:07:30PM +1000, Matthew Hawkins wrote:
>...
> I took the time to track down what caused a breakage - in an "illegal
> binary driver" (not against the law here, though defamation certainly
> is...) no less.  And contacted the vendor (separately).  Other people
> on desktop machines with an ATI card using the fglrx driver may have
> been interested to know that they can't do the benchmarking some
> people here on lkml and -mm are asking for with a current 2.6.23 git
> kernel, hence my post.
>...

But there's not much value in benchmarking if an important part of the 
performance critical code is in some undebuggable driver...

> Matt

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
