Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 43A976B0251
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 17:39:12 -0400 (EDT)
Received: by qyl38 with SMTP id 38so5506201qyl.14
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 14:39:09 -0700 (PDT)
Date: Wed, 5 Oct 2011 14:39:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, arch: Complete pagefault_disable abstraction
Message-Id: <20111005143907.09283b14.akpm@linux-foundation.org>
In-Reply-To: <1317820169.6766.20.camel@twins>
References: <1317820169.6766.20.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed, 05 Oct 2011 15:09:29 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Currently we already have pagefault_{disable,enable}() but they're
> nothing more than a glorified preempt_{disable,enable}().

That's not very accurate or useful.  Unlike preempt_disable(),
pagefault_disable() will raise the preempt count when CONFIG_PREEMPT=n.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
