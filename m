Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 8FC466B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 21:17:58 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so4554172wgb.26
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 18:17:56 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 13 Feb 2012 21:17:56 -0500
Message-ID: <CAG4AFWargAT=KuAmwV=Ufx8dqPGoa=k=EPe9d-UzqSEguSiMJQ@mail.gmail.com>
Subject: Is there a reference count for ksm shared page?
From: Jidong Xiao <jidong.xiao@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org

Hi,

I use madvise() system call to claim that my pages are mergeable, but
for some reason I want to see how many pages are shared with my pages,
is there a way to know that? For example, something like a reference
count.

Thank you!

Jidong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
