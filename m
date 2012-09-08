Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E92F26B0075
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 21:59:16 -0400 (EDT)
MIME-Version: 1.0
In-Reply-To: <504AA2F9.5060502@cn.fujitsu.com>
References: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
 <CAHGf_=o8VzFSF3kGK92bKgeWPJ4qOQ_NhCzXO-J_Ge22M7M20g@mail.gmail.com> <504AA2F9.5060502@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 7 Sep 2012 21:58:55 -0400
Message-ID: <CAHGf_=rPYAU6X2eXqyBxHV=PtguBceK=n_C89dTDbUk54-+6ww@mail.gmail.com>
Subject: Re: [PATCH] mm: fix mmap overflow checking
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaowanlong@cn.fujitsu.com
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, open@kvack.org, "list@kvack.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>

>> I've seen the exactly same patch from another fujitsu guys several
>> month ago. and as I pointed
>> out at that time, this line don't work when 32bit kernel + mmap2 syscall case.
>>
>> Please don't think do_mmap_pgoff() is for mmap(2) specific and read a
>> past thread before resend
>> a patch.
>
> So, what's your opinion about this bug? How to fix it in your mind?

Fix glibc instead of kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
