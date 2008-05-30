MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18496.1712.236440.420038@stoffel.org>
Date: Fri, 30 May 2008 09:52:48 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH 00/25] Vm Pageout Scalability Improvements (V8) -
 continued
In-Reply-To: <20080529162029.7b942a97@bree.surriel.com>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
	<20080529131624.60772eb6.akpm@linux-foundation.org>
	<20080529162029.7b942a97@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, eric.whitney@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

>>>>> "Rik" == Rik van Riel <riel@redhat.com> writes:

Rik> On Thu, 29 May 2008 13:16:24 -0700
Rik> Andrew Morton <akpm@linux-foundation.org> wrote:

>> I was >this< close to getting onto Rik's patches (honest) but a few
>> other people have been kicking the tyres and seem to have caused some
>> punctures so I'm expecting V9?

Rik> If I send you a V9 up to patch 12, you can apply Lee's patches
Rik> straight over my V9 :)

I haven't seen any performance numbers talking about how well this
stuff works on single or dual CPU machines with smaller amounts of
memory, or whether it's worth using on these machines at all?

The big machines with lots of memory and lots of CPUs are certainly
becoming more prevalent, but for my home machine with 4Gb RAM and dual
core, what's the advantage?  

Let's not slow down the common case for the sake of the bigger guys if
possible.

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
