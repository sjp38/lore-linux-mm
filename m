Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4BF6C6B004D
	for <linux-mm@kvack.org>; Sun, 19 Feb 2012 19:10:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4DF523EE0B6
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:10:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F5FF45DE52
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:10:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DD8145DE4E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:10:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F260AE08003
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:10:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AAC981DB8037
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:10:56 +0900 (JST)
Date: Mon, 20 Feb 2012 09:09:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: + memcg-remove-pcg_file_mapped.patch added to -mm tree
Message-Id: <20120220090935.1bd379b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120217214600.28F87A01B8@akpm.mtv.corp.google.com>
References: <20120217214600.28F87A01B8@akpm.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: gthelen@google.com, hannes@cmpxchg.org, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, yinghan@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hillf Danton <dhillf@gmail.com>

On Fri, 17 Feb 2012 13:46:00 -0800
akpm@linux-foundation.org wrote:

> 
> The patch titled
>      Subject: memcg: remove PCG_FILE_MAPPED
> has been added to the -mm tree.  Its filename is
>      memcg-remove-pcg_file_mapped.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Subject: memcg: remove PCG_FILE_MAPPED
> 
> With the new lock scheme for updating memcg's page stat, we don't need a
> flag PCG_FILE_MAPPED which was duplicated information of page_mapped().
> 

Johannes and Hillf pointed out this is required.
Thank you!.

==
