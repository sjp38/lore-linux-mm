Date: Tue, 22 Jan 2008 16:39:32 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080122153931.GA25936@elte.hu>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <p73hcha9vc5.fsf@bingen.suse.de> <20080119160743.GA8352@csn.ul.ie> <20080122121400.GB31253@elte.hu> <20080122122954.GC10987@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080122122954.GC10987@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> Sorry, there was a screwup on my behalf. The version I sent still had 
> a stray static inline in it.  It will fail to compile without this.

ok, picked up that fix too, thanks.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
