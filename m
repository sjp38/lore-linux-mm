Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DC03E8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 23:03:59 -0400 (EDT)
Subject: Re: [PATCH 2/8] drivers/char/random: Split out __get_random_int
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110316022804.27682.qmail@science.horizon.com>
References: <20110316022804.27682.qmail@science.horizon.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Mar 2011 22:03:56 -0500
Message-ID: <1300244636.3128.426.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2011-03-13 at 20:57 -0400, George Spelvin wrote:
> The unlocked function is needed for following work.
> No API change.

As I mentioned last time this code was discussed, we're already one
crypto-savvy attacker away from this code becoming a security hole. 
We really need to give it a serious rethink before we make it look
anything like a general-use API. 

And you've got it backwards here: __ should be the unlocked, dangerous
version. But the locked version already has a __ because it's already
dangerous.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
