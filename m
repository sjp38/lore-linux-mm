Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B6076B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 00:49:56 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n554nsTr024320
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 5 Jun 2009 13:49:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7879B45DE4F
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 13:49:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 569F545DE4E
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 13:49:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1E31DB803C
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 13:49:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C12DD1DB805E
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 13:49:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
In-Reply-To: <1244176757.11597.24.camel@localhost.localdomain>
References: <1228331069.6693.73.camel@lts-notebook> <1244176757.11597.24.camel@localhost.localdomain>
Message-Id: <20090605134641.FC25.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  5 Jun 2009 13:49:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Jon Masters <jonathan@jonmasters.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

> On Wed, 2008-12-03 at 14:04 -0500, Lee Schermerhorn wrote:
> 
> > Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):
> 
> FWIW, I really liked this patch series. And I think there is still value
> in a generic "mlock" wrapper utility that I can use. Sure, the later on
> containers suggestions are all wonderful in theory but I don't see that
> that went anywhere either (and I disagree that we can't trust people to
> use this right without doing silly things) - if I'm really right that
> this got dropped on the floor, can we resurrect it in .31 please?

I guess Lee is really really busy now.
Can you make V3 patch instead?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
