Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF27090010B
	for <linux-mm@kvack.org>; Thu, 26 May 2011 15:02:35 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4QJ24eA010079
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 12:02:06 -0700
Received: by ewy9 with SMTP id 9so526223ewy.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 12:02:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikgXhmgzQYfSWKDoxVyNuCzSM7Qxw@mail.gmail.com>
References: <4DDE2873.7060409@jp.fujitsu.com> <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
 <BANLkTikgXhmgzQYfSWKDoxVyNuCzSM7Qxw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 26 May 2011 12:01:44 -0700
Message-ID: <BANLkTin3vHzUu-p654jvkG4R1Td261b3Aw@mail.gmail.com>
Subject: Re: [PATCH] mm: don't access vm_flags as 'int'
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

On Thu, May 26, 2011 at 11:50 AM, richard -rw- weinberger
<richard.weinberger@gmail.com> wrote:
>
> This breaks kernel builds with CONFIG_HUGETLBFS=n. :-(

Grr. I did the "allyesconfig" build to find any problems, but that
obviously also sets HUGETLBFS.

But "allnoconfig" does find this.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
