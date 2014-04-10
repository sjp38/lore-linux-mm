Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id B67886B003B
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:41:31 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so3840211igb.11
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:41:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id re1si16127234igb.32.2014.04.10.07.41.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 07:41:30 -0700 (PDT)
Message-ID: <5346AD92.2080705@oracle.com>
Date: Thu, 10 Apr 2014 10:41:22 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
References: <53440991.9090001@oracle.com> <CAA_GA1d_boVA67EBK5Rv7_F_8pb_5rBA10WB9ooCdjON93C03w@mail.gmail.com> <20140410143734.GA939@redhat.com>
In-Reply-To: <20140410143734.GA939@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 04/10/2014 10:37 AM, Dave Jones wrote:
> On Thu, Apr 10, 2014 at 04:45:58PM +0800, Bob Liu wrote:
>  > On Tue, Apr 8, 2014 at 10:37 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
>  > > Hi all,
>  > >
>  > > While fuzzing with trinity inside a KVM tools guest running the latest -next
>  > > kernel, I've stumbled on the following:
>  > >
>  > 
>  > Wow! There are so many huge memory related bugs recently.
>  > AFAIR, there were still several without fix. I wanna is there any
>  > place can track those bugs instead of lost in maillist?
>  > It seems this link is out of date
>  > http://codemonkey.org.uk/projects/trinity/bugs-unfixed.php
>  
> It got to be too much for me to track tbh.
> Perhaps this is one of the cases where using bugzilla.kernel.org might
> be a useful thing ?

FWIW, I'd be happy to use something else besides having to track mail
threads and keep a list of "to-do open issues".

If folks want to start using bugzilla.kernel.org for mm/ issues I'll go
ahead and enter all the open issues in there.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
