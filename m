Date: Wed, 27 Apr 2005 16:35:46 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 4/4] VM: automatic reclaim through mempolicy
Message-Id: <20050427163546.7654efc1.akpm@osdl.org>
In-Reply-To: <20050427151010.GV8018@localhost>
References: <20050427145734.GL8018@localhost>
	<20050427151010.GV8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Martin Hicks <mort@sgi.com> wrote:
>
> This implements a set of flags that modify the behavior
> of the the mempolicies to allow reclaiming of preferred 
> memory (as definited by the mempolicy) before spilling
> onto remote nodes.  It also adds a new mempolicy
> "localreclaim" which is just the default mempolicy with
> non-zero reclaim flags.

My attention span expired, and I'm not super-familiar with the mempolicy
stuff anyway.

> The change required adding a "flags" argument to sys_set_mempolicy()
> to give hints about what kind of memory you're willing to sacrifice.

This is a back-compatible change, so current userspace will continue to
work OK, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
