Date: Wed, 22 Mar 2006 23:01:38 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 00/34] mm: Page Replacement Policy Framework
In-Reply-To: <20060322145132.0886f742.akpm@osdl.org>
Message-ID: <Pine.LNX.4.63.0603222300320.6212@cuia.boston.redhat.com>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
 <20060322145132.0886f742.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, iwamoto@valinux.co.jp, christoph@lameter.com, wfg@mail.ustc.edu.cn, npiggin@suse.de, torvalds@osdl.org, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Wed, 22 Mar 2006, Andrew Morton wrote:

> 2.6.16-rc6 seems to do OK.  I assume the cyclic patterns exploit the lru 
> worst case thing?  Has consideration been given to tweaking the existing 
> code, detect the situation and work avoid the problem?

This can certainly be done.  Rate-based clock-pro isn't that
far away mechanically from the current 2.6 code and can be
introduced in small steps.

I'll just have to make it work again ;)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
