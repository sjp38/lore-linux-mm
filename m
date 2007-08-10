Received: by wa-out-1112.google.com with SMTP id m33so771949wag
        for <linux-mm@kvack.org>; Thu, 09 Aug 2007 20:34:20 -0700 (PDT)
Message-ID: <4a5909270708092034yaa0a583w70084ef93266df48@mail.gmail.com>
Date: Thu, 9 Aug 2007 23:34:20 -0400
From: "Daniel Phillips" <daniel.raymond.phillips@gmail.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <Pine.LNX.4.64.0708091844450.3185@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
	 <200708061649.56487.phillips@phunq.net>
	 <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
	 <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
	 <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
	 <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
	 <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
	 <4a5909270708091717n2f93fcb5i284d82edfd235145@mail.gmail.com>
	 <Pine.LNX.4.64.0708091844450.3185@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On 8/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> The allocations problems that this patch addresses can be fixed by making reclaim
> more intelligent.

If you believe that the deadlock problems we address here can be
better fixed by making reclaim more intelligent then please post a
patch and we will test it.  I am highly skeptical, but the proof is in
the patch.

> If we can reclaim in an emergency even in ATOMIC contexts then things get much
> easier.

It is already easy, and it is already fixed in this patch series.
Sure, we can pare these patches down a little more, but you are going
to have a really hard time coming up with something simpler that
actually works.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
