Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 466436B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:01:44 -0500 (EST)
Date: Tue, 30 Nov 2010 20:54:56 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/2] exec: more excessive argument size fixes for
	2.6.37/stable
Message-ID: <20101130195456.GA11905@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com> <20101129182332.GA21470@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101129182332.GA21470@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On 11/29, Oleg Nesterov wrote:
>
> I was going to export get_arg_page/acct_arg_size, but it is so
> ugly.

But I think this is the only option for 2.6.37/stable.

So. I am sending 2 patches, hopefully they fix the problems
and there are simple enough for 2.6.27/stable.

> I'll try to find the way to unify copy_strings and
> compat_copy_strings, not sure it is possible to do cleanly.

I'll send the cleanups which unify compat/non-compat code on
top of these fixes, this is not stable material.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
