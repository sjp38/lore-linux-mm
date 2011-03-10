Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E9E598D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 12:04:49 -0500 (EST)
Date: Thu, 10 Mar 2011 09:03:45 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/5] make *_gate_vma accept mm_struct instead of
 task_struct II
Message-ID: <20110310170345.GE20504@alboin.amr.corp.intel.com>
References: <1299630721-4337-1-git-send-email-wilsons@start.ca>
 <20110310160032.GA20504@alboin.amr.corp.intel.com>
 <20110310163809.GA20675@alboin.amr.corp.intel.com>
 <20110310165414.GA6431@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310165414.GA6431@fibrous.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Paul Mundt <lethal@linux-sh.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 10, 2011 at 11:54:14AM -0500, Stephen Wilson wrote:
> 
> On Thu, Mar 10, 2011 at 08:38:09AM -0800, Andi Kleen wrote:
> > On Thu, Mar 10, 2011 at 08:00:32AM -0800, Andi Kleen wrote:
> > > On Tue, Mar 08, 2011 at 07:31:56PM -0500, Stephen Wilson wrote:
> > > > The only architecture this change impacts in any significant way is x86_64.
> > > > The principle change on that architecture is to mirror TIF_IA32 via
> > > > a new flag in mm_context_t. 
> > > 
> > > The problem is -- you're adding a likely cache miss on mm_struct for
> > > every 32bit compat syscall now, even if they don't need mm_struct
> > > currently (and a lot of them do not) Unless there's a very good
> > > justification to make up for this performance issue elsewhere
> > > (including numbers) this seems like a bad idea.
> > 
> > Hmm I see you're only setting it on exec time actually on rereading
> > the patches. I thought you were changing TS_COMPAT which is in
> > the syscall path.
> > 
> > Never mind.  I have no problems with doing such a change on exec
> > time.
> 
> OK.  Great!  Does this mean I have your ACK'ed by or reviewed by?

I didn't read it all, but the first two patches looked ok.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
