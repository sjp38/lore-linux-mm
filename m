Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 58A806B007E
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 16:39:17 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1769743bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 13:39:15 -0700 (PDT)
Date: Sun, 1 Apr 2012 00:39:12 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120331203912.GB687@moon>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120331201324.GA17565@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-security-module@vger.kernel.org, oprofile-list@lists.sf.net, Matt Helsley <matthltc@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Sat, Mar 31, 2012 at 10:13:24PM +0200, Oleg Nesterov wrote:
> 
> Add Cyrill. This conflicts with
> c-r-prctl-add-ability-to-set-new-mm_struct-exe_file.patch in -mm.

Thanks for CC'ing, Oleg. I think if thise series go in it won't
be a problem to update my patch accordingly.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
