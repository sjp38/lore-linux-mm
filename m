Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4F8DC6B007E
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 18:48:48 -0400 (EDT)
Date: Fri, 6 Apr 2012 15:48:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-Id: <20120406154846.ada3cf0f.akpm@linux-foundation.org>
In-Reply-To: <4F7A8544.2020603@openvz.org>
References: <20120331091049.19373.28994.stgit@zurg>
	<20120331092929.19920.54540.stgit@zurg>
	<20120402231837.GC32299@count0.beaverton.ibm.com>
	<4F7A8544.2020603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, 03 Apr 2012 09:06:12 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Ok, I'll resend this patch as independent patch-set,
> anyway I need to return mm->mmap_sem locking back.

We need to work out what to do with "c/r: prctl: add ability to set new
mm_struct::exe_file".  I'm still sitting on the 3.4 c/r patch queue for
various reasons, one of which is that I need to go back and re-review
all the discussion, which was lengthy.  Early next week, hopefully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
