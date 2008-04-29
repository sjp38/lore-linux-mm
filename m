Received: by wr-out-0506.google.com with SMTP id c37so214328wra.26
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 12:23:03 -0700 (PDT)
Message-ID: <84144f020804291223x6e40509fk8461ed4d96d443b@mail.gmail.com>
Date: Tue, 29 Apr 2008 22:23:02 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [2/2] vmallocinfo: Add caller information
In-Reply-To: <Pine.LNX.4.64.0804291204450.12689@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318222701.788442216@sgi.com>
	 <20080318222827.519656153@sgi.com> <20080429084854.GA14913@elte.hu>
	 <Pine.LNX.4.64.0804291001420.10847@schroedinger.engr.sgi.com>
	 <20080428124849.4959c419@infradead.org>
	 <Pine.LNX.4.64.0804291143080.12128@schroedinger.engr.sgi.com>
	 <20080428140026.32aaf3bf@infradead.org>
	 <Pine.LNX.4.64.0804291204450.12689@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 10:09 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  Well so we display out of whack backtraces? There are also issues on
>  platforms that do not have a stack in the classic sense (rotating register
>  file on IA64 and Sparc64 f.e.). Determining a backtrace can be very
>  expensive.

I think that's the key question here whether we need to enable this on
production systems? If yes, why? If it's just a debugging aid, then I
see Ingo's point of save_stack_trace(); otherwise the low-overhead
__builtin_return_address() makes more sense.

And btw, why is this new file not in /sys/kernel....?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
