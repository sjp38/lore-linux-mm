Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 6642E6B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 20:18:49 -0400 (EDT)
Received: by mail-da0-f53.google.com with SMTP id n34so1588455dal.26
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 17:18:48 -0700 (PDT)
Message-ID: <5169F5E7.3070100@gmail.com>
Date: Sat, 13 Apr 2013 17:18:47 -0700
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Return value of __mm_populate
References: <51694C2A.4050906@gmail.com>
In-Reply-To: <51694C2A.4050906@gmail.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, kosaki.motohiro@gmail.com, lkml <linux-kernel@vger.kernel.org>

(4/13/13 5:14 AM), Marco Stornelli wrote:
> Hi,
> 
> I was seeing the code of __mm_populate (in -next) and I've got a doubt 
> about the return value. The function __mlock_posix_error_return should 
> return a proper error for mlock, converting the return value from 
> __get_user_pages. It checks for EFAULT and ENOMEM. Actually 
> __get_user_pages could return, in addition, ERESTARTSYS and EHWPOISON. 

__get_user_pages doesn't return EHWPOISON if FOLL_HWPOISON is not specified.
I'm not expert ERESTARTSYS. I understand correctly, ERESTARTSYS is only returned
when signal received, and signal handling routine (e.g. do_signal) modify EIP and
hidden ERESTARTSYS from userland generically.


> So it seems to me that we could return to user space not expected value. 
> I can't see them on the man page. In addition we shouldn't ever return 
> ERESTARTSYS to the user space but EINTR. According to the man pages 
> maybe we should return EAGAIN in these cases. Am I missing something?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
