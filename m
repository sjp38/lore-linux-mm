Subject: Re: 2.4.14 + Bug in swap_out.
References: <Pine.LNX.4.33L.0111211016270.4079-100000@imladris.surriel.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 21 Nov 2001 06:31:51 -0700
In-Reply-To: <Pine.LNX.4.33L.0111211016270.4079-100000@imladris.surriel.com>
Message-ID: <m1hero1c8o.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 20 Nov 2001, Eric W. Biederman wrote:
> > "David S. Miller" <davem@redhat.com> writes:
> >
> > > I do not agree with your analysis.
> >
> > Neither do I now but not for your reasons :)
> >
> > I looked again we are o.k. but just barely.  mmput explicitly checks
> > to see if it is freeing the swap_mm, and fixes if we are.  It is a
> > nasty interplay with the swap_mm global, but the code is correct.
> 
> To be honest I don't see the reason for this subtle
> playing with swap_mm in mmput(), since the refcounting
> should mean we're safe.

We only hold a ref count for the duration of swap_out_mm.
Not for the duration of the value in swap_mm.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
