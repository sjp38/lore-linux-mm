Date: Tue, 21 Oct 2008 22:55:13 -0400
From: Daniel Jacobowitz <dan@debian.org>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
Message-ID: <20081022025513.GA7504@caradoc.them.org>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu> <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu> <20081021124130.a002e838.akpm@linux-foundation.org> <20081021202410.GA10423@us.ibm.com> <48FE82DF.6030005@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48FE82DF.6030005@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, tglx@linutronix.de, dave@linux.vnet.ibm.com, mingo@elte.hu, hpa@zytor.com, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 09:33:19PM -0400, Oren Laadan wrote:
> >> What happens if I pass it a pid of a process which I _do_ own, but it
> >> does not refer to a container's init process?
> > 
> > I would assume that do_checkpoint() would return -EINVAL, but it's a
> > great question:  Oren, did you have another plan?
> 
> Since we intentional provide minimal functionality to keep the patchset
> simple and allow easy review - we only checkpoint one task; it doesn't
> really matter because we don't deal with the entire container.
> 
> With the ability to checkpoint multiple process we will have to ensure
> that we checkpoint an entire container. I planned to return -EINVAL if
> the target task isn't a container init(1). Another option, if people
> prefer, is to use any task in a container to "represent" the entire
> container.

I haven't been following - but why this whole container restriction?
Checkpoint/restart of individual processes is very useful too.
There are issues with e.g. IPC, but I'm not convinced they're
substantially different than the issues already present for a
container.

-- 
Daniel Jacobowitz
CodeSourcery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
