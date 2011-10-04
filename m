Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F14DE900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:29:05 -0400 (EDT)
Received: by qyl38 with SMTP id 38so3523394qyl.14
        for <linux-mm@kvack.org>; Tue, 04 Oct 2011 06:29:04 -0700 (PDT)
MIME-Version: 1.0
From: Prateek Sharma <prateek3.14@gmail.com>
Date: Tue, 4 Oct 2011 18:58:44 +0530
Message-ID: <CAKwxwqw-8xK68zKXxh2LJapQxkgM=Uu6DPq90aQcsN+FUtu3tg@mail.gmail.com>
Subject: page-cache hit ratio
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello ,
   I would like to know if there is any existing mechanism in the
kernel to get the page-cache statistics like hit-ratios etc.
So far i have found 2 ways of doing this:
First is to instrument the find_get_page routine using ftrace
trace-events, as done here : [http://lkml.org/lkml/2011/7/21/25] .
The other is to use something like system tap :
http://serverfault.com/questions/157612/is-there-a-way-to-get-cache-hit-miss-ratios-for-block-devices-in-linux

However i seem to getting different results from these two approaches.
I'd like to know if there is any framework for evaluating linux-mm
performance (which has cache statistics) ?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
