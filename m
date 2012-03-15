Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 975C06B004D
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 16:19:15 -0400 (EDT)
Date: Thu, 15 Mar 2012 13:19:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Too much free memory (not used for FS cache)
Message-Id: <20120315131913.657d4f3d.akpm@linux-foundation.org>
In-Reply-To: <4F624C88.6050503@suse.cz>
References: <4F624C88.6050503@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, Jiri Slaby <jirislaby@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 15 Mar 2012 21:09:44 +0100
Jiri Slaby <jslaby@suse.cz> wrote:

> since today's -next (20120315), the MM/VFS system is very sluggish.
> Especially when committing, diffing and similar with git. I still have
> 2G of 6G of memory free. But with each commit I have to wait for git to
> fetch all data from disk.
> 
> I'm using ext4 on a raid for the partition with git kernel repository if
> that matters.
> 
> Any idea what that could be?

The last mm->next update was March 5th so it won't be from stuff in the
-mm queue.

Are you sure it's reclaim-related?  Perhaps something in the IO system
got slow?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
