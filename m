Date: Fri, 28 Nov 2008 10:45:54 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC v10][PATCH 02/13] Checkpoint/restart: initial
	documentation
Message-ID: <20081128104554.GP28946@ZenIV.linux.org.uk>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu> <1227747884-14150-3-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1227747884-14150-3-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 26, 2008 at 08:04:33PM -0500, Oren Laadan wrote:

> +Currently, namespaces are not saved or restored. They will be treated
> +as a class of a shared object. In particular, it is assumed that the
> +task's file system namespace is the "root" for the entire container.
> +It is also assumed that the same file system view is available for the
> +restart task(s). Otherwise, a file system snapshot is required.

That is to say, bindings are not handled at all.

> +* What additional work needs to be done to it?

> +We know this design can work.  We have two commercial products and a
> +horde of academic projects doing it today using this basic design.

May I use that for a t-shirt, please?  With that quote in foreground, and
pus-yellow-greenish "MACH" serving as background.  With the names of products
and projects dripping from it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
