Date: Fri, 27 Apr 2007 00:02:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/10] SLUB: Fix sysfs directory handling
In-Reply-To: <20070426233138.5c6707b7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704270001230.5388@schroedinger.engr.sgi.com>
References: <20070427042655.019305162@sgi.com> <20070427042907.759384015@sgi.com>
 <20070426233138.5c6707b7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007, Andrew Morton wrote:

> > + * :[flags-]size:[memory address of kmemcache]
> > + */
> 
> Exposing kernel addresses to unprivileged userspace is considered poor
> form.

Hmmmm... We could drop the address if I can make sure that all the other
unifying bits are in the string.
 
> And it'd be (a bit) nice to have something which is consistent across
> boots, I guess.

That'd do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
