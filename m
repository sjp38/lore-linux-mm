Date: Sat, 17 Apr 2004 11:33:25 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417183325.GN743@holomorphy.com>
References: <20040417060920.GC29393@flea> <20040417061847.GC743@holomorphy.com> <20040417175723.GA3235@flea> <20040417181042.GM743@holomorphy.com> <20040417182838.GA3856@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417182838.GA3856@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 11:10:42AM -0700, William Lee Irwin III wrote:
>> I'm not sure it's expected. Maybe this patch fares better?

On Sat, Apr 17, 2004 at 11:28:38AM -0700, Marc Singer wrote:
> Ah, that's a much different thing.  That works for me.  Is that
> something you'd want to put into the kernel?

Since we have a coherent story about this working for you, I think
we should probably send it upstream for review. I don't have a
particular opinion about it being the right thing to do, as since it's
a policy decision, it's rather arbitrary.

If this is important to you, it may help to numerically quantify your
results, e.g. some before/after benchmark/throughput/whatever numbers.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
