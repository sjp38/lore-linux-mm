Date: Sun, 23 Oct 2005 23:40:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] cpuset confine pdflush to its cpuset
Message-Id: <20051023234032.5e926336.akpm@osdl.org>
In-Reply-To: <20051023233237.0982b54b.pj@sgi.com>
References: <20051024001913.7030.71597.sendpatchset@jackhammer.engr.sgi.com>
	<20051024.145258.98349934.taka@valinux.co.jp>
	<20051023233237.0982b54b.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: taka@valinux.co.jp, Simon.Derr@bull.net, linux-kernel@vger.kernel.org, clameter@sgi.com, torvalds@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> wrote:
>
> Takahashi-san wrote:
> > I realized CPUSETS has another problem around pdflush.
> 
> Excellent observation.  I had not realized this.
> 
> Thank-you for pointing it out.
> 
> I don't have plans.  Do you have any suggestions?

Per-zone dirty thresholds (quite messy), per-zone writeback (horrific,
linear searches or data structure proliferation everywhere).

Let's see a (serious) worload/testcase first, hey?  vmscan.c writeback off
the LRU is a bit slow, but we should be able to make it suffice.

>   ( Anyone know what the "pd" stands for in pdflush ?? )

"page dirty"?  It's what bdflush became when writeback went from
being block-based to being page-based.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
