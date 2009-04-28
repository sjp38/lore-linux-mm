Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C952D6B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:48:55 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090428014920.769723618@intel.com>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 12:49:21 -0500
Message-Id: <1240940961.938.451.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 09:09 +0800, Wu Fengguang wrote:
> plain text document attachment (kpageflags-extending.patch)
> Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.

My only concern with this patch is it knows a bit too much about SLUB
internals (and perhaps not enough about SLOB, which also overloads
flags). 

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
