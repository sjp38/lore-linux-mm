Subject: Re: [RFC] Enabling other oom schemes
From: Robert Love <rml@tech9.net>
In-Reply-To: <3F614912.3090801@genebrew.com>
References: <200309120219.h8C2JANc004514@penguin.co.intel.com>
	 <3F614912.3090801@genebrew.com>
Content-Type: text/plain
Message-Id: <1063342032.700.234.camel@localhost>
Mime-Version: 1.0
Date: Fri, 12 Sep 2003 00:47:13 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rahul Karnik <rahul@genebrew.com>
Cc: rusty@linux.co.intel.com, riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-09-12 at 00:18, Rahul Karnik wrote:

> How does this interact with the overcommit handling? Doesn't strict 
> overcommit also not oom, but rather return a memory allocation error?

Right.  Technically, with strict overcommit and a sufficient overcommit
ratio, you cannot OOM.

But this is for people who do have a chance of OOM, because strict
overcommit is not for everyone.

> Could we not add another overcommit mode where oom conditions cause a 
> kernel panic?

The two are unrelated.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
