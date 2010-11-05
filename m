Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1B87F8D0001
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 13:47:49 -0400 (EDT)
Date: Fri, 5 Nov 2010 18:41:42 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] (Was: oom: fix oom_score_adj consistency with
	oom_disable_count)
Message-ID: <20101105174142.GA19469@redhat.com>
References: <201010262121.o9QLLNFo016375@imap1.linux-foundation.org> <20101101024949.6074.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011738200.26266@chino.kir.corp.google.com> <alpine.DEB.2.00.1011021741520.21871@chino.kir.corp.google.com> <20101103112324.GA29695@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101103112324.GA29695@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roland McGrath <roland@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, JANAK DESAI <janak@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 11/03, Oleg Nesterov wrote:
>
> However. Please do not touch this code. It doesn't work anyway,
> I'll resend the patch which removes this crap.

This code continues to confuse developers. And this is the only
effect it has.

Once again. The patch removes the DEAD code. It is never called,
it can't work (from 2006) but this is not immediately clear.
Howver it often needs attention/changes because it _looks_ as if
it works.

Let's remove it, finally.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
