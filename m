Received: by rv-out-0910.google.com with SMTP id f1so69588rvb
        for <linux-mm@kvack.org>; Tue, 31 Jul 2007 23:19:37 -0700 (PDT)
Message-ID: <b21f8390707312319l3ffd8e7cn85984e32344a41f2@mail.gmail.com>
Date: Wed, 1 Aug 2007 16:19:36 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: SD still better than CFS for 3d ?
In-Reply-To: <20070801052513.GL3972@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com>
	 <930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com>
	 <20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site>
	 <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>
	 <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com>
	 <20070730182959.GA29151@infradead.org> <adaps29sm62.fsf@cisco.com>
	 <b21f8390707302007n2f21018crc6b7cd83666e0f3c@mail.gmail.com>
	 <20070801052513.GL3972@stusta.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@stusta.de>
Cc: Roland Dreier <rdreier@cisco.com>, Christoph Hellwig <hch@infradead.org>, Jacob Braun <jwbraun@gmail.com>, kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On 8/1/07, Adrian Bunk <bunk@stusta.de> wrote:
> But there's not much value in benchmarking if an important part of the
> performance critical code is in some undebuggable driver...

In this case we don't care about the performance of the video driver.
This isn't a race to see who can get the most fps.  The driver can be
thought of as a black box so long as comparative benchmarks are done
with the same driver.

What we're looking for primarily is progress or regress in
interactivity under load with different cpu schedulers, and secondly
the effect of swap prefetch.  The video driver is irrelevant -
especially considering the people doing this testing have a wide
variety of video cards.  This is why I have included some commentary
on "feel" because that's the important part.

Ingo specifically asked for CFS v20 in 2.6.23 to be included in the
testing (its not available separately on his website), hence the need
to be able to bring up one's usual working environment under that
kernel also so the results aren't skewed by driver artifacts.

For my next trick, I'll attempt to quantify the "feel" bits using
scheduler statistics.
While riding a unicycle.

Okay, scratch the unicycle ;-)

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
