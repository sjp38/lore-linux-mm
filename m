Date: Thu, 18 Jul 2002 19:50:28 +0200 (MEST)
From: Szakacsits Szabolcs <szaka@sienet.hu>
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
In-Reply-To: <1027016939.1086.127.camel@sinai>
Message-ID: <Pine.LNX.4.30.0207181942240.30902-100000@divine.city.tvnet.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 18 Jul 2002, Robert Love wrote:
> An orthogonal issue is per-user resource limits and this may need to be
> coupled with that.  It is not a problem I am trying to solve, however.

About 99% of the people don't know about, don't understand or don't
care about resource limits. But they do care about cleaning up when
mess comes. Adding reserved root memory would be a couple of lines,
you can get ideas from the patch from here,
	http://mlf.linux.rulez.org/mlf/ezaz/reserved_root_memory.html

Surprisingly visited through google and people are asking for 2.4
patches, hint ;)

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
