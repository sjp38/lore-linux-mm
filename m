Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 26ECE6B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 16:34:55 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oB9LYqQB005708
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 13:34:52 -0800
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by wpaz24.hot.corp.google.com with ESMTP id oB9LYoa4017189
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 13:34:51 -0800
Received: by pxi4 with SMTP id 4so1070754pxi.30
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 13:34:50 -0800 (PST)
Date: Thu, 9 Dec 2010 13:34:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: continuous oom caused system deadlock
In-Reply-To: <328504308.562701291863164154.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1012091334040.13564@chino.kir.corp.google.com>
References: <328504308.562701291863164154.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010, caiqian@redhat.com wrote:

> The version is 2010-11-23-16-12 which included b52723c5 you mentioned. 
> 2.6.37-rc5 had the same problem.
> 

The problem with your bisect is that you're bisecting in between 696d3cd5 
and b52723c5 and identifying a problem that has already been fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
