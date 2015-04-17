Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 861AC6B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 00:19:20 -0400 (EDT)
Received: by qgej70 with SMTP id j70so16286309qge.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 21:19:20 -0700 (PDT)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com. [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id hi9si10576367qcb.46.2015.04.16.21.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 21:19:19 -0700 (PDT)
Received: by qcrf4 with SMTP id f4so18129355qcr.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 21:19:18 -0700 (PDT)
Date: Fri, 17 Apr 2015 00:18:43 -0400
From: Michael Tirado <mtirado418@gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd:
 F_SEAL_WRITE_NONCREATOR
Message-ID: <20150417001843.2b88d733@yak.slack>
In-Reply-To: <CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
References: <20150416032316.00b79732@yak.slack>
	<CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org

On Thu, 16 Apr 2015 11:14:11 +0300
Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> Keeping pointer to priviledged task is a bad idea.
> There is no easy way to drop it when task exits and this doesn't work
> for threads.
> I think it's better to keep pointer to priveledged struct file and
> drop it in method
> f_op->release() when task closes fd or exits. Server task could obtain second
> non-priveledged fd and struct file for that inode via
> open(/proc/../fd/), dup3(),
> openat() or something else and send it to read-only users.

Thank you, I was hoping someone would suggest a different authentication 
method, I will look into this idea.  What is the thread concern?  I have 
not run in to any problems yet while testing, but have been more focused 
on getting my user space memfd transport daemon up and running before I put 
it through the torture test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
