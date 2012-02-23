Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 33C226B00F4
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:52:51 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120223135049.24278.76524.stgit@warthog.procyon.org.uk>
References: <20120223135049.24278.76524.stgit@warthog.procyon.org.uk> <20120223135035.24278.96099.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH 2/3] NOMMU: Merge __put_nommu_region() into put_nommu_region()
Date: Thu, 23 Feb 2012 13:52:45 +0000
Message-ID: <24439.1330005165@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: dhowells@redhat.com, linux-mm@kvack.org, uclinux-dev@uclinux.org, gerg@uclinux.org, lethal@linux-sh.org, Al Viro <viro@zeniv.linux.org.uk>

David Howells <dhowells@redhat.com> wrote:

> Merge __put_nommu_region() into put_nommu_region() in the NOMMU mmap code as
> that's the only remaining user.
> 
> Reported-by: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>

Actually, this isn't a bugfix and could wait for the next merge window.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
