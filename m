Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C20316B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 15:01:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so40950801wma.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 12:01:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mc8si25741936wjb.284.2016.12.07.12.01.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 12:01:29 -0800 (PST)
Subject: Re: mlockall() with pid parameter
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
 <52a0d9c3-5c9a-d207-4cbc-a6df27ba6a9c@suse.cz>
 <CACKey4yB_qXdRn1=qNu65GA0ER-DL+DEqhP9QRGkWX79jVao8g@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ef9a07bc-e0d9-46ed-8898-7db6b1d4cb9f@suse.cz>
Date: Wed, 7 Dec 2016 21:01:14 +0100
MIME-Version: 1.0
In-Reply-To: <CACKey4yB_qXdRn1=qNu65GA0ER-DL+DEqhP9QRGkWX79jVao8g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Federico Reghenzani <federico.reghenzani@polimi.it>
Cc: linux-mm@kvack.org

On 12/07/2016 05:33 PM, Federico Reghenzani wrote:
> 
> 
> 2016-12-07 17:21 GMT+01:00 Vlastimil Babka <vbabka@suse.cz
> <mailto:vbabka@suse.cz>>:
> 
>     On 12/07/2016 04:39 PM, Federico Reghenzani wrote:
>     > Hello,
>     >
>     > I'm working on Real-Time applications in Linux. `mlockall()` is a
>     > typical syscall used in RT processes in order to avoid page faults.
>     > However, the use of this syscall is strongly limited by ulimits, so
>     > basically all RT processes that want to call `mlockall()` have to be
>     > executed with root privileges.
> 
>     Is it not possible to change the ulimits with e.g. prlimit?
> 
> 
> Yes, but it requires a synchronization between non-root process and root
> process.
> Because the root process has to change the limits before the non-root
> process executes the mlockall().

Would it work if you did that between fork() and exec()? If you can
spawn them like this, that is.

> Just to provide an example, another syscall used in RT tasks is the
> sched_setscheduler() that also suffers
> the limitation of ulimits, but it accepts the pid so the scheduling
> policy can be enforced by a root process to
> any other process.
>  
>  
> 
>     > What I would like to have is a syscall that accept a "pid", so a process
>     > spawned by root would be able to enforce the memory locking to other
>     > non-root processes. The prototypes would be:
>     >
>     > int mlockall(int flags, pid_t pid);
>     > int munlockall(pid_t pid);
>     >
>     > I checked the source code and it seems to me quite easy to add this
>     > syscall variant.
>     >
>     > I'm writing here to have a feedback before starting to edit the code. Do
>     > you think that this is a good approach?
>     >
>     >
>     > Thank you,
>     > Federico
>     >
>     > --
>     > *Federico Reghenzani*
>     > PhD Candidate
>     > Politecnico di Milano
>     > Dipartimento di Elettronica, Informazione e Bioingegneria
>     >
> 
> 
> 
> 
> -- 
> *Federico Reghenzani*
> PhD Candidate
> Politecnico di Milano
> Dipartimento di Elettronica, Informazione e Bioingegneria
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
