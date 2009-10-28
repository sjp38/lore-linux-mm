Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B107C6B008A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 20:39:36 -0400 (EDT)
Received: by bwz7 with SMTP id 7so400203bwz.6
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:39:32 -0700 (PDT)
Message-ID: <4AE792B8.5020806@gmail.com>
Date: Wed, 28 Oct 2009 01:39:20 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> This is wrong; it doesn't "emulate oom" since oom_kill_process() always 
> kills a child of the selected process instead if they do not share the 
> same memory.  The chosen task in that case is untouched.

OK, I stand corrected then. Thanks! But, while testing this I lost X
once again and "test" survived for some time (check the timestamps):

http://pastebin.com/d5c9d026e

- It started by killing gkrellm(!!!)
- Then I lost X (kdeinit4 I guess)
- Then 103 seconds after the killing started, it killed "test" - the
real culprit.

I mean... how?!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
