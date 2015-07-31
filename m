From: Borislav Petkov <bp@alien8.de>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Date: Fri, 31 Jul 2015 16:44:52 +0200
Message-ID: <20150731144452.GA8106@nazgul.tnic>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
 <20150731131802.GW25159@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150731131802.GW25159@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, hpa@zytor.com, dvlasenk@redhat.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, luto@amacapital.net, mcgrof@suse.com, toshi.kani@hp.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org
List-Id: linux-mm.kvack.org

On Fri, Jul 31, 2015 at 03:18:02PM +0200, Peter Zijlstra wrote:
> Using these functions with preemption enabled is racy against MTRR
> updates. And if that race is ok, at the very least explain that it is
> indeed racy and why this is not a problem.

Right, so Luis has been working on burying direct MTRR access so
after that work is done, we'll be using only PAT for changing memory
attributes. Look at arch_phys_wc_add() and all those fbdev users of
mtrr_add() which get converted to that thing...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
