Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 031C86B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 22:03:07 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 263363EE0BB
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 12:03:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D56B45DEDA
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 12:03:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA01A45DED8
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 12:03:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C09371DB8047
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 12:03:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F00D1DB8043
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 12:03:05 +0900 (JST)
Date: Tue, 10 Jan 2012 12:01:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: vmscan: cleanup with s/reclaim_mode/isolate_mode/
Message-Id: <20120110120118.994b0bc4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBBifQggNFtBsq0-Q_fG6mOJ-rJ544Me9pLFXbMi3Xn0gQ@mail.gmail.com>
References: <CAJd=RBBifQggNFtBsq0-Q_fG6mOJ-rJ544Me9pLFXbMi3Xn0gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Fri, 6 Jan 2012 22:01:03 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> With tons of reclaim_mode(defined as one field of struct scan_control) already
> in the file, it is clearer to rename it when setting up the isolation mode.
> 
> 
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

I like this.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
