Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 761A96B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 11:21:55 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so39045727wme.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:21:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e126si9087947wme.41.2016.12.07.08.21.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 08:21:53 -0800 (PST)
Subject: Re: mlockall() with pid parameter
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <52a0d9c3-5c9a-d207-4cbc-a6df27ba6a9c@suse.cz>
Date: Wed, 7 Dec 2016 17:21:38 +0100
MIME-Version: 1.0
In-Reply-To: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Federico Reghenzani <federico.reghenzani@polimi.it>, linux-mm@kvack.org

On 12/07/2016 04:39 PM, Federico Reghenzani wrote:
> Hello,
> 
> I'm working on Real-Time applications in Linux. `mlockall()` is a
> typical syscall used in RT processes in order to avoid page faults.
> However, the use of this syscall is strongly limited by ulimits, so
> basically all RT processes that want to call `mlockall()` have to be
> executed with root privileges.

Is it not possible to change the ulimits with e.g. prlimit?

> What I would like to have is a syscall that accept a "pid", so a process
> spawned by root would be able to enforce the memory locking to other
> non-root processes. The prototypes would be:
> 
> int mlockall(int flags, pid_t pid);
> int munlockall(pid_t pid);
> 
> I checked the source code and it seems to me quite easy to add this
> syscall variant.
> 
> I'm writing here to have a feedback before starting to edit the code. Do
> you think that this is a good approach?
> 
> 
> Thank you,
> Federico
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
