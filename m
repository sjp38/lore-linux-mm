Received: by wa-out-1112.google.com with SMTP id m33so1056646wag
        for <linux-mm@kvack.org>; Fri, 10 Aug 2007 16:25:35 -0700 (PDT)
Message-ID: <4a5909270708101625q407a240ck6109ef536fdbed4a@mail.gmail.com>
Date: Fri, 10 Aug 2007 19:25:34 -0400
From: "Daniel Phillips" <daniel.raymond.phillips@gmail.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <Pine.LNX.4.64.0708101041040.12758@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
	 <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
	 <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
	 <4a5909270708091717n2f93fcb5i284d82edfd235145@mail.gmail.com>
	 <Pine.LNX.4.64.0708091844450.3185@schroedinger.engr.sgi.com>
	 <4a5909270708092034yaa0a583w70084ef93266df48@mail.gmail.com>
	 <Pine.LNX.4.64.0708092045120.27164@schroedinger.engr.sgi.com>
	 <4a5909270708100115v4ad10c4es697d216edf29b07d@mail.gmail.com>
	 <Pine.LNX.4.64.0708101041040.12758@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On 8/10/07, Christoph Lameter <clameter@sgi.com> wrote:
> The idea of adding code to deal with "I have no memory" situations
> in a kernel that based on have as much memory as possible in use at all
> times is plainly the wrong approach.

No.  It is you who have read the patches wrongly, because what you
imply here is exactly backwards.

> If you need memory then memory needs
> to be reclaimed. That is the basic way that things work

Wrong.  A naive reading of your comment would suggest you do not
understand how PF_MEMALLOC works, and that it has worked that way from
day one (well, since long before I arrived) and that we just do more
of the same, except better.

> and following that
> through brings about a much less invasive solution without all the issues
> that the proposed solution creates.

What issues?  Test case please, a real one that you have run yourself.
 Please, no more theoretical issues that cannot be demonstrated in
practice because they do not exist.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
