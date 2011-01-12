Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AFF3E6B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 10:40:38 -0500 (EST)
Received: by iyj17 with SMTP id 17so635684iyj.14
        for <linux-mm@kvack.org>; Wed, 12 Jan 2011 07:40:37 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 12 Jan 2011 18:40:37 +0300
Message-ID: <AANLkTin_-bH09WK43DS9p0Kpp=7y6iHbLnUrCtOc6Qy5@mail.gmail.com>
Subject: cgroups and overcommit question
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

When I forbid memory overcommiting, malloc() returns 0 if can't
reserve memory, but in a cgroup it will always succeed, when it can
succeed when not in the group.
E.g. I've set 2 to overcommit_memory, limit is 10M: I can ask malloc
100M and it will not return any error (kernel is 2.6.32).
Is it expected behavior?

-- 
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
