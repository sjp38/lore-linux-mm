Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 59FDF6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 04:53:10 -0400 (EDT)
Received: by wguu7 with SMTP id u7so30519800wgu.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 01:53:09 -0700 (PDT)
Received: from johanna1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id fi8si24191326wib.10.2015.07.01.01.53.08
        for <linux-mm@kvack.org>;
        Wed, 01 Jul 2015 01:53:08 -0700 (PDT)
Date: Wed, 1 Jul 2015 11:53:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
Message-ID: <20150701085304.GA18268@node.dhcp.inet.fi>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
 <1431623414-1905-6-git-send-email-sasha.levin@oracle.com>
 <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue, Jun 30, 2015 at 04:35:45PM -0700, David Rientjes wrote:
> I do understand the problem with the current VM_BUG_ON_PAGE() and 
> VM_BUG_ON_VMA() stuff, and it compels me to ask about just going back to 
> the normal
> 
> 	VM_BUG_ON(cond);
> 
> coupled with dump_page(), dump_vma(), dump_whatever().  It all seems so 
> much simpler to me.

Is there a sensible way to couple them? I don't see much, except opencode
VM_BUG_ON():

	if (IS_ENABLED(CONFIG_DEBUG_VM) && cond) {
		dump_page(...);
		dump_vma(...);
		dump_whatever();
		BUG();
	}

That's too verbose to me to be usable.

BTW, I also tried[1] to solve this problem too, but people doesn't like
either.

[1] http://lkml.kernel.org/g/1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
