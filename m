Date: Sat, 17 Apr 2004 12:45:17 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417194517.GQ743@holomorphy.com>
References: <20040417060920.GC29393@flea> <20040417061847.GC743@holomorphy.com> <20040417175723.GA3235@flea> <20040417181042.GM743@holomorphy.com> <20040417182838.GA3856@flea> <20040417183325.GN743@holomorphy.com> <20040417184424.GA4066@flea> <20040417191955.GO743@holomorphy.com> <20040417192547.GA11065@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417192547.GA11065@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 12:19:55PM -0700, William Lee Irwin III wrote:
>> That's something of a normative question about the heuristics, and I
>> try to steer clear of those, though I'm not entirely sure that's how I
>> would interpret it the tunings for your descriptive parts.

On Sat, Apr 17, 2004 at 12:25:47PM -0700, Marc Singer wrote:
> The more I think about it, the more I think that there is something
> awry.  Once distress reaches 50, swappiness is going to rule the
> ability of the system to keep pages mapped.  If swappiness is then 50
> or more, vmscan is going age and then purge every mapped page.

There's not any a priori reason to believe this is wrong that I know of,
though it looks like things do better for you when slightly rearranged.


On Sat, Apr 17, 2004 at 12:19:55PM -0700, William Lee Irwin III wrote:
>> In the absence of "hard" numbers, you might still be able to use things
>> like wall clock timings. Another thing that would help is to expose the
>> thing to a variety of workloads/etc. For that, I guess I post to lkml.

On Sat, Apr 17, 2004 at 12:25:47PM -0700, Marc Singer wrote:
> Are you suggesting that I post to LKML to get some ideas about other
> workloads?

Well, yes, but I just did so myself.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
