Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 821786B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:48:33 -0400 (EDT)
Message-ID: <51695273.6080800@alice.it>
Date: Sat, 13 Apr 2013 14:41:23 +0200
From: Marco <firefox82@alice.it>
MIME-Version: 1.0
Subject: Re: Return value of __mm_populate
References: <51694C2A.4050906@gmail.com>
In-Reply-To: <51694C2A.4050906@gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

Adding in cc: lkml

Il 13/04/2013 14:14, Marco Stornelli ha scritto:
> Hi,
>
> I was seeing the code of __mm_populate (in -next) and I've got a doubt
> about the return value. The function __mlock_posix_error_return should
> return a proper error for mlock, converting the return value from
> __get_user_pages. It checks for EFAULT and ENOMEM. Actually
> __get_user_pages could return, in addition, ERESTARTSYS and EHWPOISON.
> So it seems to me that we could return to user space not expected value.
> I can't see them on the man page. In addition we shouldn't ever return
> ERESTARTSYS to the user space but EINTR. According to the man pages
> maybe we should return EAGAIN in these cases. Am I missing something?
>
> Thanks,
>
> Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
