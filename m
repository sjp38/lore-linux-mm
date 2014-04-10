Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B99B6B0038
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:37:51 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so3087285eek.22
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:37:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l41si6326860eef.68.2014.04.10.07.37.47
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 07:37:48 -0700 (PDT)
Date: Thu, 10 Apr 2014 10:37:34 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
Message-ID: <20140410143734.GA939@redhat.com>
References: <53440991.9090001@oracle.com>
 <CAA_GA1d_boVA67EBK5Rv7_F_8pb_5rBA10WB9ooCdjON93C03w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1d_boVA67EBK5Rv7_F_8pb_5rBA10WB9ooCdjON93C03w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 10, 2014 at 04:45:58PM +0800, Bob Liu wrote:
 > On Tue, Apr 8, 2014 at 10:37 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
 > > Hi all,
 > >
 > > While fuzzing with trinity inside a KVM tools guest running the latest -next
 > > kernel, I've stumbled on the following:
 > >
 > 
 > Wow! There are so many huge memory related bugs recently.
 > AFAIR, there were still several without fix. I wanna is there any
 > place can track those bugs instead of lost in maillist?
 > It seems this link is out of date
 > http://codemonkey.org.uk/projects/trinity/bugs-unfixed.php
 
It got to be too much for me to track tbh.
Perhaps this is one of the cases where using bugzilla.kernel.org might
be a useful thing ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
