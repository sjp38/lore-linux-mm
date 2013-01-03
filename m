Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B2C706B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 13:55:06 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id fw7so15740591vcb.17
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 10:55:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121222094545.GA4222@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
 <CALCETrUi4JJSahrDKBARrwGsGE=1RbH8WL4tk1YgDmEowzXtSQ@mail.gmail.com>
 <CANN689H+yOeA3pvBMGu52q7brfoDwtkh0pA==c8VVoCkapkx6g@mail.gmail.com>
 <CALCETrU7u7P67QCwmj4qTMHti1=MXyjy3V9FejWbbrMVi01mDw@mail.gmail.com>
 <CANN689GBCsZWKkAQuNGfF4OJwVOyZ5neUcJo=ajzMKNmFug+XQ@mail.gmail.com>
 <CALCETrUOXjm6uoZ=TwyPr0_EQT-10ko5k448FwGP_dMwb=v=AA@mail.gmail.com>
 <CANN689G-+Dns7BEJVG1SNO_CYA1vCEhiyf7F90sKYPvrNsXN9w@mail.gmail.com> <20121222094545.GA4222@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 3 Jan 2013 10:54:44 -0800
Message-ID: <CALCETrU6CAFTUi8t8BzGx6jYe6GuzmUfVyVc=HjWbiY81-MmMQ@mail.gmail.com>
Subject: Re: [PATCH 10/9] mm: make do_mmap_pgoff return populate as a size in
 bytes, not as a bool
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 22, 2012 at 1:45 AM, Michel Lespinasse <walken@google.com> wrote:
> do_mmap_pgoff() rounds up the desired size to the next PAGE_SIZE multiple,
> however there was no equivalent code in mm_populate(), which caused issues.
>
> This could be fixed by introduced the same rounding in mm_populate(),
> however I think it's preferable to make do_mmap_pgoff() return populate
> as a size rather than as a boolean, so we don't have to duplicate the
> size rounding logic in mm_populate().
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

This appears to fix my hangs.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
