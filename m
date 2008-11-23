Date: Sun, 23 Nov 2008 10:24:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-Id: <20081123102453.f549da39.akpm@linux-foundation.org>
In-Reply-To: <20081123091843.GK30453@elte.hu>
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>
	<20081123091843.GK30453@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Waychison <mikew@google.com>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Sun, 23 Nov 2008 10:18:44 +0100 Ingo Molnar <mingo@elte.hu> wrote:

> * Ying Han <yinghan@google.com> wrote:
> 
> > page fault retry with NOPAGE_RETRY
> 
> Interesting patch.

<a grey call stirs>

ahhh...  I thought this all sounded familiar.  It surfaced a couple of
years ago, and this was my summary of the intent at the time:

http://lkml.indiana.edu/hypermail/linux/kernel/0609.1/2106.html

It all went round and round for a while, but I don't think anything got
merged.  In fact I can't even find Ben's original little spufs/cell
NOPAGE_RETRY code in the tree, an I thought we merged that.  Confused.

The questions are, of course: does this new code address the issues
which were raised at that time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
