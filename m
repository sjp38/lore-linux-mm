Date: Thu, 28 Apr 2005 08:56:04 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH/RFC 4/4] VM: automatic reclaim through mempolicy
Message-ID: <20050428125604.GH19244@localhost>
References: <20050427145734.GL8018@localhost> <20050427151010.GV8018@localhost> <20050427163546.7654efc1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050427163546.7654efc1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Martin Hicks <mort@sgi.com>, linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, Apr 27, 2005 at 04:35:46PM -0700, Andrew Morton wrote:
> Martin Hicks <mort@sgi.com> wrote:
> 
> > The change required adding a "flags" argument to sys_set_mempolicy()
> > to give hints about what kind of memory you're willing to sacrifice.
> 
> This is a back-compatible change, so current userspace will continue to
> work OK, yes?

I suspect not.  sys_set_mempolicy() takes an extra arg now, so I'd guess
that it'll pull in junk for the "flags" argument during a syscall and
most likely return -EINVAL due to invalid flags (or you'll get yourself
a localreclaim policy).

Sorry for not warning about that.
mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
