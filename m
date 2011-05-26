Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 98C3C6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 13:54:30 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4QHruaW002917
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 10:53:57 -0700
Received: by eyd9 with SMTP id 9so539370eyd.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 10:53:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDE2873.7060409@jp.fujitsu.com>
References: <4DDE2873.7060409@jp.fujitsu.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 26 May 2011 10:53:34 -0700
Message-ID: <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
Subject: Re: [PATCH] mm: don't access vm_flags as 'int'
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

2011/5/26 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> The type of vma->vm_flags is 'unsigned long'. Neither 'int' nor
> 'unsigned int'. This patch fixes such misuse.

I applied this, except I also just made the executive decision to
replace things with "vm_flags_t" after all.

Which leaves a lot of "unsigned long" users that aren't converted, but
right now it doesn't matter, and it can be converted piecemeal as
people notice users..

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
