Date: Wed, 16 Jun 2004 14:30:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-Id: <20040616143040.403bf68b.akpm@osdl.org>
In-Reply-To: <20040616142413.GA5588@sgi.com>
References: <20040616142413.GA5588@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dimitri Sivanich <sivanich@sgi.com> wrote:
>
> In the process of testing per/cpu interrupt response times and CPU availability,
> I've found that running cache_reap() as a timer as is done currently results
> in some fairly long CPU holdoffs.

Before patching anything I want to understand what's going on in there. 
Please share your analysis.


How long?

How many objects?

Which slab?

Why?

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
