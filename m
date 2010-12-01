Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CBFB66B0085
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:09:50 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB139mcf022275
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 12:09:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0806C45DE79
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:09:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D938D45DE6E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:09:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BAA331DB8037
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:09:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A56E38001
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:09:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] exec: unify compat/non-compat code
In-Reply-To: <20101130200016.GD11905@redhat.com>
References: <20101130195456.GA11905@redhat.com> <20101130200016.GD11905@redhat.com>
Message-Id: <20101201120806.ABB9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 12:09:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

> (remove stable)
> 
> On 11/30, Oleg Nesterov wrote:
> >
> > I'll send the cleanups which unify compat/non-compat code on
> > top of these fixes, this is not stable material.
> 
> On top of
> 
> 	[PATCH 1/2] exec: make argv/envp memory visible to oom-killer
> 	[PATCH 2/2] exec: copy-and-paste the fixes into compat_do_execve() paths
> 
> Imho, execve code in fs/compat.c must die. It is very hard to
> maintain this copy-and-paste horror.

I strongly like this series. (yes, I made fault to forgot to change compat.c
multiple times ;)

Unfortunatelly, this is a bit large and I have no time now. I expect I
can review this at this or next weekend.....
Hopefully, anyoneelse will review this and ignore me....



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
