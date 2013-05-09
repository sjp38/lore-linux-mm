Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CFB306B0032
	for <linux-mm@kvack.org>; Thu,  9 May 2013 10:33:24 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id k14so1967814oag.36
        for <linux-mm@kvack.org>; Thu, 09 May 2013 07:33:24 -0700 (PDT)
Received: from [192.168.0.100] (69-196-135-35.dsl.teksavvy.com. [69.196.135.35])
        by mx.google.com with ESMTPSA id n6sm3404831oel.8.2013.05.09.07.33.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 May 2013 07:33:23 -0700 (PDT)
Message-ID: <518BB3B1.8010207@gmail.com>
Date: Thu, 09 May 2013 10:33:21 -0400
From: Ben Teissier <ben.teissier@gmail.com>
MIME-Version: 1.0
Subject: misunderstanding of the virtual memory
References: <518BB132.5050802@gmail.com>
In-Reply-To: <518BB132.5050802@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Hi,

I'm Benjamin and I'm studying the kernel. I write you this email
because I've a trouble with the mmu and the virtual memory. I try to
understand how a program (user land) can write something into the stack
(push ebp, for example), indeed, the program works with virtual address
(between 0x00000 and 0x8... if my memory is good) but at the hardware
side the address is not the same (that's why mmu was created, if I'm right).

My problem is the following : how the data is wrote on the physical
memory. When I try a strace (kernel 2.6.32 on a simple program) I have
no hint on the transfer of data. Moreover, according to the wikipedia
web page on syscall (
https://en.wikipedia.org/wiki/System_call#The_library_as_an_intermediary
), a call is not managed by the kernel. So, how the transfer between
virtual memory and physical memory is possible ?

I hope my email is understandable, I tried to put words on my troubles.

Thanks a lot for your help and have a nice day.

Benjamin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
