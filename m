Date: Sat, 5 Jul 2003 03:44:33 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1
Message-ID: <20030705104433.GK955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <20030704210737.GI955@holomorphy.com> <20030704181539.2be0762a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030704181539.2be0762a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2003 at 06:15:39PM -0700, Andrew Morton wrote:
> Look at select_bad_process(), and the ->mm test in badness().  pdflush
> can never be chosen.
> Nevertheless, there have been several report where kernel threads _are_ 
> being hit my the oom killer.  Any idea why that is?

The badness() check isn't good enough. If badness() returns 0 for all
processes with pid's > 0 and the first one seen is a kernel thread the
kernel thread will be chosen. In principle, one could merely retarget
chosen with points >= maxpoints, but that's trivially defeated by
kernel threads landing at the highest pid for whatever reason.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
