Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B43FF6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 11:59:44 -0500 (EST)
Received: by pxi12 with SMTP id 12so1889265pxi.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 08:59:41 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 22 Nov 2010 19:59:41 +0300
Message-ID: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
Subject: Question about cgroup hierarchy and reducing memory limit
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I have following cgroup hierarchy:

  Root
  /   |
A   B

A and B have memory limits set so that it's 100% of limit set in Root.
I want to add C to root:

  Root
  /   |  \
A   B  C

What is correct way to shrink limits for A and B? When they use all
allowed memory and I try to write to their limit files I get error. It
seems, that I can shrink their limits multiple times by 1Mb and it
works, but looks ugly and like very dirty workaround.


-- 
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
