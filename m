Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CDD206B0047
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 19:58:15 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o1L0wBSj017354
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 00:58:11 GMT
Received: from vws20 (vws20.prod.google.com [10.241.21.148])
	by wpaz33.hot.corp.google.com with ESMTP id o1L0w9YB031587
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 16:58:10 -0800
Received: by vws20 with SMTP id 20so234026vws.31
        for <linux-mm@kvack.org>; Sat, 20 Feb 2010 16:58:08 -0800 (PST)
Date: Sat, 20 Feb 2010 16:58:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/18] sysctl extern cleanup - mm
In-Reply-To: <20100220141241.GE3195@darkstar>
Message-ID: <alpine.DEB.2.00.1002201657020.20140@chino.kir.corp.google.com>
References: <20100220141241.GE3195@darkstar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, James Morris <jmorris@namei.org>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 2010, Dave Young wrote:

> Extern declarations in sysctl.c should be move to their own head file,
> and then include them in relavant .c files.
> 
> Move min_free_kbytes extern declaration to linux/mm.h
> 

It should be moved to include/linux/mmzone.h, that's where the sysctl 
handler is declared.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
