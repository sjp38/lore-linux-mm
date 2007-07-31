Received: by rv-out-0910.google.com with SMTP id f1so395384rvb
        for <linux-mm@kvack.org>; Mon, 30 Jul 2007 20:07:30 -0700 (PDT)
Message-ID: <b21f8390707302007n2f21018crc6b7cd83666e0f3c@mail.gmail.com>
Date: Tue, 31 Jul 2007 13:07:30 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: SD still better than CFS for 3d ?
In-Reply-To: <adaps29sm62.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com>
	 <20070729204716.GB1578@elte.hu>
	 <930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com>
	 <20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site>
	 <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>
	 <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com>
	 <20070730182959.GA29151@infradead.org> <adaps29sm62.fsf@cisco.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland Dreier <rdreier@cisco.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jacob Braun <jwbraun@gmail.com>, kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On 7/31/07, Roland Dreier <rdreier@cisco.com> wrote:
>  >      Fuck you Martin!
>
> I think you meant to yell at Matthew, not Martin ;)

What's amusing about this is he's yelling at me for something I didn't
do, can't even get my name right, and has the audacity to claim that
*I* am the one looking like a fool!  While we're descending into
primary school theatrics, may I just say "takes one to know one" ;-)

I took the time to track down what caused a breakage - in an "illegal
binary driver" (not against the law here, though defamation certainly
is...) no less.  And contacted the vendor (separately).  Other people
on desktop machines with an ATI card using the fglrx driver may have
been interested to know that they can't do the benchmarking some
people here on lkml and -mm are asking for with a current 2.6.23 git
kernel, hence my post.

Martin's cleanup patch is good and I never claimed otherwise, I just
said the comment on the commit was a bad call (as there are users of
that interface).  Certainly ATI should fix their dodgy drivers.
That's been the cry of the community for a long time...

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
