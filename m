Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 063FC6B025A
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 11:16:09 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so62115156wic.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:16:08 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id lr7si1017970wjb.35.2015.09.11.08.16.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 08:16:07 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so68048751wic.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:16:07 -0700 (PDT)
Date: Fri, 11 Sep 2015 17:16:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mlock.2: mlock2.2: Add entry to for new mlock2 syscall
Message-ID: <20150911151605.GL3417@dhcp22.suse.cz>
References: <1441030820-2960-1-git-send-email-emunson@akamai.com>
 <55F14E05.6020304@suse.cz>
 <20150911145712.GA3452@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150911145712.GA3452@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, mtk.manpages@gmail.com, Jonathan Corbet <corbet@lwn.net>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-09-15 10:57:12, Eric B Munson wrote:
> On Thu, 10 Sep 2015, Vlastimil Babka wrote:
[...]
> > Also, what about glibc wrapper for mlock2()? Does it have to come before or
> > after the manpage and who gets it in?
> 
> V3 now has an updated version, hopefully mlock2 hits the 4.4 merge
> window.
> 
> I don't know about the glibc wrapper, are we expected to write one
> ourselves?  Will they even take it?  They haven't been the most open
> minded about taking wrappers for system calls that are unique to Linux
> in the past.

I do not think we really do care about the glibc wrapper. There are many
syscalls which do not have it either (e.g. gettid).

But I guess it would be worth noting this in the man page the same way
as gettid does.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
