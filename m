Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id B7ACC6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:22:17 -0500 (EST)
Date: Thu, 23 Feb 2012 12:22:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Message-Id: <20120223122215.d280b090.akpm@linux-foundation.org>
In-Reply-To: <1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
References: <20120222150010.c784b29b.akpm@linux-foundation.org>
	<1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, Mike Frysinger <vapier@gentoo.org>

On Thu, 23 Feb 2012 09:33:31 +0530
Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com> wrote:

> With this patch in place, /proc/PID/task/TID/maps are treated as 'maps
> as the task would see it' and hence, only the vma that that task uses
> as stack is marked as [stack]. All other 'stack' vmas are marked as
> anonymous memory. /proc/PID/maps acts as a thread group level view,
> where all stack vmas are marked.

Looks OK to me, thanks.  I doubt if those interface changes will cause
significant disruption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
