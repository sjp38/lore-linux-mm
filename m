Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0FB8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 21:10:40 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0CD973EE081
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:10:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C4245DE4D
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:10:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF1E245DD74
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:10:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C1CDA1DB8038
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:10:36 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D9571DB802C
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:10:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <20110308105458.7EA2.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com> <20110308105458.7EA2.A69D9226@jp.fujitsu.com>
Message-Id: <20110308111001.7EA8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 11:10:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> I don't understand you think which task is eligible and unnecessary.
> But, Look! Andrey is not talking about zombie process case. But, this v2
> patch have factored out other tasks too. This IS the problem. No need
             ^^^^^^^^
             filter.

I need to rest.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
