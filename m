Date: Wed, 21 Nov 2001 10:17:07 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.14 + Bug in swap_out.
In-Reply-To: <m1lmh01vg0.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0111211016270.4079-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 20 Nov 2001, Eric W. Biederman wrote:
> "David S. Miller" <davem@redhat.com> writes:
>
> > I do not agree with your analysis.
>
> Neither do I now but not for your reasons :)
>
> I looked again we are o.k. but just barely.  mmput explicitly checks
> to see if it is freeing the swap_mm, and fixes if we are.  It is a
> nasty interplay with the swap_mm global, but the code is correct.

To be honest I don't see the reason for this subtle
playing with swap_mm in mmput(), since the refcounting
should mean we're safe.

Rik
-- 
Shortwave goes a long way:  irc.starchat.net  #swl

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
