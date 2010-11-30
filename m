Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E880F6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:06:50 -0500 (EST)
Date: Tue, 30 Nov 2010 21:00:16 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/4] exec: unify compat/non-compat code
Message-ID: <20101130200016.GD11905@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com> <20101129182332.GA21470@redhat.com> <20101130195456.GA11905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130195456.GA11905@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

(remove stable)

On 11/30, Oleg Nesterov wrote:
>
> I'll send the cleanups which unify compat/non-compat code on
> top of these fixes, this is not stable material.

On top of

	[PATCH 1/2] exec: make argv/envp memory visible to oom-killer
	[PATCH 2/2] exec: copy-and-paste the fixes into compat_do_execve() paths

Imho, execve code in fs/compat.c must die. It is very hard to
maintain this copy-and-paste horror.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
