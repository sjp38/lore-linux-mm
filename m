Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 371836B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 12:37:48 -0400 (EDT)
Date: Wed, 3 Aug 2011 09:37:45 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mmotm 2011-08-02-16-19 uploaded (fault-inject.h)
Message-Id: <20110803093745.0fcb7b76.rdunlap@xenotime.net>
In-Reply-To: <201108022357.p72NvsZM022462@imap1.linux-foundation.org>
References: <201108022357.p72NvsZM022462@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Tue, 02 Aug 2011 16:19:30 -0700 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-08-02-16-19 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
>    git://zen-kernel.org/kernel/mmotm.git
> or
>    git://git.cmpxchg.org/linux-mmotm.git
> 
> It contains the following patches against 3.0:

> fault-injection-add-ability-to-export-fault_attr-in-arbitrary-directory.patch

Please drop the ';' at the end of the second line below:

+static inline struct dentry *fault_create_debugfs_attr(const char *name,
+			struct dentry *parent, struct fault_attr *attr);
 {
+	return ERR_PTR(-ENODEV);
 }

It causes lots of build errors.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
