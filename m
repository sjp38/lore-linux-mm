Subject: Re: [RFC PATCH 4/4] kmemtrace: SLOB hooks.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <84144f020807170043w725769e5i7c24402613711690@mail.gmail.com>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
	 <9e4ab51fe29754243e4577dec4649c5522ddd4f8.1216255036.git.eduard.munteanu@linux360.ro>
	 <84144f020807170043w725769e5i7c24402613711690@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 17 Jul 2008 10:46:38 -0500
Message-Id: <1216309598.29259.0.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-17 at 10:43 +0300, Pekka Enberg wrote:
> Hi,
> 
> [Adding Matt as cc.]
> 
> On Thu, Jul 17, 2008 at 3:46 AM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.
> >
> > Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> 
> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
