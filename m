Received: by nz-out-0506.google.com with SMTP id s1so120644nze
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 03:34:00 -0700 (PDT)
Message-ID: <84144f020707250333gc1c2f01l24c7b9ff6211a489@mail.gmail.com>
Date: Wed, 25 Jul 2007 13:33:55 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
In-Reply-To: <Pine.LNX.4.64.0707242009080.3583@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
	 <20070724165914.a5945763.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707241705380.9633@schroedinger.engr.sgi.com>
	 <20070724175332.41ade708.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707242009080.3583@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Christoph Lameter <clameter@sgi.com> wrote:
> Yes I thought that to be the appropriate time for such things too and I
> wanted to keep things the way they were until 2.6.24. But that no longer
> seems to be the case. The destructor patch was only merged a few days ago
> and it already breaks my other slab patches that I am holding. If we do
> this then lets do a comprehensive job. I do not want to get through
> another cycle of this next time. At some point all this slab API stuff
> should be done.

We're gonna have API breakage with kmem_cache_ops thing too, right?
And that's not going to make it in 2.6.24 anyway, so I don't see the
problem with resending this to Andrew at -rc7 or so.

                                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
