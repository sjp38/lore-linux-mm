Date: Mon, 17 Mar 2008 09:17:35 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
Message-ID: <20080317081735.GI27015@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015825.0C0171B41E0@basil.firstfloor.org> <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com> <20080317070208.GC27015@one.firstfloor.org> <86802c440803170017r622114bdpede8625d1a8ff585@mail.gmail.com> <86802c440803170031u75167e5m301f65049b6d62ff@mail.gmail.com> <20080317074146.GG27015@one.firstfloor.org> <86802c440803170053n32a1c918h2ff2a32abef44050@mail.gmail.com> <86802c440803170110l2e47c25bu2adb16b094d2867f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803170110l2e47c25bu2adb16b094d2867f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 01:10:31AM -0700, Yinghai Lu wrote:
> please check the one against -mm and x86.git

No offset is not enough because it is still relative to the zone
start. I'm preparing an updated patch.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
