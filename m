Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EE8856B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 21:43:07 -0400 (EDT)
Date: Tue, 15 Sep 2009 18:42:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.32 -mm merge plans (cgroups)
Message-Id: <20090915184237.13160e2a.akpm@linux-foundation.org>
In-Reply-To: <6599ad830909151740n2affe0daw27618ccae9c737d6@mail.gmail.com>
References: <6599ad830909151740n2affe0daw27618ccae9c737d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Sep 2009 17:40:15 -0700 Paul Menage <menage@google.com> wrote:

> How much longer is the merge window open for?

A week.

> It's probably safest to
> hold these in -mm for now since we've not resolved the potential races
> in the signal handler accesses; I'll try to find some time to work on
> them this week or next.

It's not a great time to be fixing these things up.

What would happen if we merged it as-is?  Can we be confident that the
resulting bugs won't impact others and that we can get them all fixed
up reasonably promptly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
