Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 30AC16B006E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 05:06:36 -0400 (EDT)
Received: by qyl38 with SMTP id 38so4811466qyl.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 02:06:34 -0700 (PDT)
MIME-Version: 1.0
From: Prateek Sharma <prateek3.14@gmail.com>
Date: Wed, 12 Oct 2011 14:36:14 +0530
Message-ID: <CAKwxwqwR=YAAsqORK7LsUYAu-RjjByfJhCh=CC4iSzVmW5FFHw@mail.gmail.com>
Subject: VmTrace equivalent ?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello all,
Is there an equivalent/port of the Vmtrace patch to measure page
reference patterns ?
[http://linux-mm.org/VmTrace]

In general, there is no useful memory management info exposed by the
kernel - things like working set size, page cache hit ratios, 'hot'
pages, etc.
Are there any patches/techniques already available or do i need to
implement even such basic functionality ?

Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
