Date: Wed, 22 Oct 2008 10:29:07 -0400
From: Daniel Jacobowitz <dan@debian.org>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
Message-ID: <20081022142907.GA13574@caradoc.them.org>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu> <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu> <20081021124130.a002e838.akpm@linux-foundation.org> <20081021202410.GA10423@us.ibm.com> <48FE82DF.6030005@cs.columbia.edu> <20081022025513.GA7504@caradoc.them.org> <1224644563.1848.232.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224644563.1848.232.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 08:02:43PM -0700, Dave Hansen wrote:
> Let's say you have a process you want to checkpoint.  If it uses a
> completely discrete IPC namespace, you *know* that nothing else depends
> on those IPC ids.  We don't even have to worry about who might have been
> using them and when.
> 
> Also think about pids.  Without containers, how can you guarantee a
> restarted process that it can regain the same pid?

OK, that makes sense.  In a lot of simple cases you can get by without
regaining the same pid; there's an implementation of checkpointing in
GDB that works by injecting fork calls into the child, and it is
useful for a reasonable selection of single-threaded programs.

-- 
Daniel Jacobowitz
CodeSourcery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
