From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch improvements
Date: Tue, 22 May 2007 20:54:46 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705222037.54741.kernel@kolivas.org> <20070522104648.GA10622@elte.hu>
In-Reply-To: <20070522104648.GA10622@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705222054.46488.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Antonino Ingargiola <tritemio@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 22 May 2007 20:46, Ingo Molnar wrote:
> It clearly should not consider 'itself' as IO activity. This suggests
> some bug in the 'detect activity' mechanism, agreed? I'm wondering
> whether you are seeing the same problem, or is all swap-prefetch IO on
> your system continuous until it's done [or some other IO comes
> inbetween]?

When nothing else is happening anywhere on the system it reads in bursts and 
goes to sleep during journal writeout.
 
-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
