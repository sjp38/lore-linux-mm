Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 420146B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 12:40:06 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so106592520pgc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 09:40:06 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a9si24867024pgn.328.2016.12.07.09.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 09:40:05 -0800 (PST)
Subject: Re: mlockall() with pid parameter
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4664bc3f-67b8-af11-3f98-a7d480996f5f@intel.com>
Date: Wed, 7 Dec 2016 09:40:04 -0800
MIME-Version: 1.0
In-Reply-To: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Federico Reghenzani <federico.reghenzani@polimi.it>, linux-mm@kvack.org, Vlastimil Babka <VBabka@suse.com>

On 12/07/2016 07:39 AM, Federico Reghenzani wrote:
> What I would like to have is a syscall that accept a "pid", so a process
> spawned by root would be able to enforce the memory locking to other
> non-root processes. The prototypes would be:
> 
> int mlockall(int flags, pid_t pid);
> int munlockall(pid_t pid);

The prototypes don't really tell enough of the story to give you good
feedback.  For instance, whose rlimit do these count against?  Are all
the MCL_CURRENT/FUTURE/FAULT flags supported?

I think you need to start implementing something to actually see how
ugly this gets in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
