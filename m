Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1DC1B6B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 20:45:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B0jEDp005806
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 09:45:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0251545DE79
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 09:45:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC1F645DE60
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 09:45:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B48A9E38003
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 09:45:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 685E21DB803B
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 09:45:10 +0900 (JST)
Date: Fri, 11 Jun 2010 09:40:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] signals: introduce send_sigkill() helper
Message-Id: <20100611094045.8f6e5218.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100610010023.GB4727@redhat.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
	<20100608210000.7692.A69D9226@jp.fujitsu.com>
	<20100608184144.GA5914@redhat.com>
	<20100610005937.GA4727@redhat.com>
	<20100610010023.GB4727@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 03:00:23 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> Cleanup, no functional changes.
> 
> There are a lot of buggy SIGKILL users in kernel. For example, almost
> every force_sig(SIGKILL) is wrong. force_sig() is not safe, it assumes
> that the task has the valid ->sighand, and in general it should be used
> only for synchronous signals. send_sig(SIGKILL, p, 1) or
> send_xxx(SEND_SIG_FORCED/SEND_SIG_PRIV) is not right too but this is not
> immediately obvious.
> 
> The only way to correctly send SIGKILL is send_sig_info(SEND_SIG_NOINFO)
> but we do not want to use this directly, because we can optimize this
> case later. For example, zap_pid_ns_processes() allocates sigqueue for
> each process in namespace, this is unneeded.
> 
> Introduce the trivial send_sigkill() helper on top of send_sig_info()
> and change zap_pid_ns_processes() as an example.
> 
> Note: we need more cleanups here, this is only the first change.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
