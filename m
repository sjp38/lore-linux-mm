From: Borislav Petkov <bp@alien8.de>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Date: Fri, 31 Jul 2015 17:27:13 +0200
Message-ID: <20150731152713.GA9756@nazgul.tnic>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
 <20150731131802.GW25159@twins.programming.kicks-ass.net>
 <20150731144452.GA8106@nazgul.tnic>
 <20150731150806.GX25159@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150731150806.GX25159@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, hpa@zytor.com, dvlasenk@redhat.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, luto@amacapital.net, mcgrof@suse.com, toshi.kani@hp.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org
List-Id: linux-mm.kvack.org

On Fri, Jul 31, 2015 at 05:08:06PM +0200, Peter Zijlstra wrote:
> But its things like set_memory_XX(), and afaict that's all buggy against
> MTRR modifications.

I think the idea is to not do any MTRR modifications at some point:

>From Documentation/x86/pat.txt:

"... Ideally mtrr_add() usage will be phased out in favor of
arch_phys_wc_add() which will be a no-op on PAT enabled systems. The
region over which a arch_phys_wc_add() is made, should already have been
ioremapped with WC attributes or PAT entries, this can be done by using
ioremap_wc() / set_memory_wc()."

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
