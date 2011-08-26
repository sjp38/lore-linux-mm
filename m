Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBB86B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 21:04:56 -0400 (EDT)
Date: Thu, 25 Aug 2011 18:07:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Neaten warn_alloc_failed
Message-Id: <20110825180734.9beae279.akpm@linux-foundation.org>
In-Reply-To: <1314319088.19476.17.camel@Joe-Laptop>
References: <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
	<20110825165006.af771ef7.akpm@linux-foundation.org>
	<1314316801.19476.6.camel@Joe-Laptop>
	<20110825170534.0d425c75.akpm@linux-foundation.org>
	<1314319088.19476.17.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Aug 2011 17:38:08 -0700 Joe Perches <joe@perches.com> wrote:

> So if you really like it that much:

Well I don't particularly like it, personally.  But they're there, so
we either fully use them or fully unuse them, then remove them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
