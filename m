Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 479D48D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 21:44:11 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p262i9n8021269
	for <linux-mm@kvack.org>; Sat, 5 Mar 2011 18:44:09 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz37.hot.corp.google.com with ESMTP id p262hqQg024690
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2011 18:44:08 -0800
Received: by pxi9 with SMTP id 9so791927pxi.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 18:44:05 -0800 (PST)
Date: Sat, 5 Mar 2011 18:44:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <1299286307-4386-1-git-send-email-avagin@openvz.org>
Message-ID: <alpine.DEB.2.00.1103051843490.8779@chino.kir.corp.google.com>
References: <1299286307-4386-1-git-send-email-avagin@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 5 Mar 2011, Andrey Vagin wrote:

> When we check that task has flag TIF_MEMDIE, we forgot check that
> it has mm. A task may be zombie and a parent may wait a memor.
> 
> v2: Check that task doesn't have mm one time and skip it immediately
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
