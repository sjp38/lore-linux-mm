Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A8C1B6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:28:25 -0400 (EDT)
Message-ID: <1338445696.19369.27.camel@cr0>
Subject: Re: [RFC Patch] fs: implement per-file drop caches
From: Cong Wang <amwang@redhat.com>
Date: Thu, 31 May 2012 14:28:16 +0800
In-Reply-To: <20422.14538.833061.105058@quad.stoffel.home>
References: <1338385120-14519-1-git-send-email-amwang@redhat.com>
	 <20422.14538.833061.105058@quad.stoffel.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Keiichi Kii <k-keiichi@bx.jp.nec.com>

On Wed, 2012-05-30 at 11:12 -0400, John Stoffel wrote:
> Cong> This is a draft patch of implementing per-file drop caches.
> 
> Interesting.  So can I do this from outside a process?  I'm a
> SysAdmin, so my POV is from noticing, finding and fixing performance
> problems when the system is under pressure.  

Yes, sure, we need to write a utility (or patch an existing one) to do
this for you admins.

> 
> Cong> It introduces a new fcntl command  F_DROP_CACHES to drop
> Cong> file caches of a specific file. The reason is that currently
> Cong> we only have a system-wide drop caches interface, it could
> Cong> cause system-wide performance down if we drop all page caches
> Cong> when we actually want to drop the caches of some huge file.
> 
> How can I tell how much cache is used by a file?  And what is the
> performance impact of this when run on a busy system?  And what does
> this patch buy us since I figure the VM should already be dropping
> caches once the system comes under mem pressure...
> 

AFAIK, we don't export such information to user-space, we only have
system-wide statistics.

Keiichi (in Cc) once wrote a patch to implement page cache tracepoint:
http://marc.info/?l=linux-mm&m=131102496904326&w=3

but the patches are still not in upstream.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
