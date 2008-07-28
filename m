Date: Mon, 28 Jul 2008 13:30:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
Message-Id: <20080728133030.8b29fa5a.akpm@linux-foundation.org>
In-Reply-To: <488DFFB0.1090107@gmail.com>
References: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
	<488DF119.2000004@gmail.com>
	<20080729012656.566F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<488DFFB0.1090107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 19:19:44 +0200
Andrea Righi <righi.andrea@gmail.com> wrote:

> KOSAKI Motohiro wrote:
> >> yep! clear.
> >>
> >> Ok, in this case wouldn't be better at least to define pud_free() as:
> >>
> >> static inline pud_free(struct mm_struct *mm, pmd_t *pmd)
> >> {
> >> }
> > 
> > I also like this :)
> 
> ok, a simpler patch using the inline function will follow.
> 

I can second that.  See
http://userweb.kernel.org/~akpm/mmotm/broken-out/include-asm-generic-pgtable-nopmdh-macros-are-noxious-reason-435.patch

Ingo cruelly ignored it.  Probably he's used to ignoring the comit
storm which I send in his direction - I'll need to resend it sometime.

I'd consider that patch to be partial - we should demacroize the
surrounding similar functions too.  But that will require a bit more
testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
