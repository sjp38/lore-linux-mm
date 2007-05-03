From: Con Kolivas <kernel@kolivas.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Date: Fri, 4 May 2007 08:14:26 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070503155407.GA7536@elte.hu>
In-Reply-To: <20070503155407.GA7536@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705040814.26902.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 04 May 2007 01:54, Ingo Molnar wrote:
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> > - If replying, please be sure to cc the appropriate individuals.
> >   Please also consider rewriting the Subject: to something
> >   appropriate.

> i've reviewed it once again and in the !CONFIG_SWAP_PREFETCH case it's a
> clear NOP, while in the CONFIG_SWAP_PREFETCH=y case all the feedback
> i've seen so far was positive. Time to have this upstream and time for a
> desktop-oriented distro to pick it up.
>
> I think this has been held back way too long. It's .config selectable
> and it is as ready for integration as it ever is going to be. So it's a
> win/win scenario.
>
> Acked-by: Ingo Molnar <mingo@elte.hu>

Thank you very much for code review, ack and support!

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
