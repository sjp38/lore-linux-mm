Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 367BA6B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 07:00:34 -0400 (EDT)
From: Al Boldi <a1426z@gawab.com>
Subject: Re: compcache as a pre-swap area
Date: Sat, 15 Aug 2009 14:00:52 +0300
References: <200908122007.43522.ngupta@vflare.org> <4A84EDE4.1080605@vflare.org> <200908141849.19797.a1426z@gawab.com>
In-Reply-To: <200908141849.19797.a1426z@gawab.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908151400.52554.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Al Boldi wrote:
> Nitin Gupta wrote:
> > On 08/14/2009 09:32 AM, Al Boldi wrote:
> > > So once compcache fills up, it will start to age its contents into
> > > normal swap?
> >
> > This is desirable but not yet implemented. For now, if 'backing swap' is
> > used, compcache will forward incompressible pages to the backing swap
> > device. If compcache fills up, kernel will simply send further swap-outs
> > to swap device which comes next in priority.
>
> Ok, this sounds acceptable for now.
>
> The important thing now is to improve performance to a level comparable to
> a system with normal ssd-swap.  Do you have such a comparisson?
>
> Another interresting benchmark would be to use compcache in a maximized
> configuration, ie. on a system w/ 1024KB Ram assign 960KB for compcache and
> leave 64KB for the system, and then see how it performs.  This may easily
> pinpoint any bottlenecks compcache has, if any.

I am wondering, is it possible to run a system in 64KB?

Ok, make that MB instead.


Thanks!

--
Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
