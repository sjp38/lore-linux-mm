Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 935C86B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 03:33:08 -0400 (EDT)
Received: by mail-ea0-f174.google.com with SMTP id m14so1796540eaj.33
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 00:33:06 -0700 (PDT)
Message-ID: <516A5A02.9090606@gmail.com>
Date: Sun, 14 Apr 2013 09:25:54 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: Re: Return value of __mm_populate
References: <51694C2A.4050906@gmail.com> <5169F5E7.3070100@gmail.com>
In-Reply-To: <5169F5E7.3070100@gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>

Hi,

Il 14/04/2013 02:18, KOSAKI Motohiro ha scritto:
> (4/13/13 5:14 AM), Marco Stornelli wrote:
>> Hi,
>>
>> I was seeing the code of __mm_populate (in -next) and I've got a doubt
>> about the return value. The function __mlock_posix_error_return should
>> return a proper error for mlock, converting the return value from
>> __get_user_pages. It checks for EFAULT and ENOMEM. Actually
>> __get_user_pages could return, in addition, ERESTARTSYS and EHWPOISON.
>
> __get_user_pages doesn't return EHWPOISON if FOLL_HWPOISON is not specified.
> I'm not expert ERESTARTSYS. I understand correctly, ERESTARTSYS is only returned
> when signal received, and signal handling routine (e.g. do_signal) modify EIP and
> hidden ERESTARTSYS from userland generically.
>

Yep, you're right, the "magic" is inside the signal management. Thanks!!

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
