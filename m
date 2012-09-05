Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id DB4536B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 20:45:20 -0400 (EDT)
Received: by qady1 with SMTP id y1so48240qad.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 17:45:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120904221641.GL3334@redhat.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
	<1346750457-12385-3-git-send-email-walken@google.com>
	<20120904142745.GE3334@redhat.com>
	<20120904215347.GA6769@google.com>
	<20120904221641.GL3334@redhat.com>
Date: Tue, 4 Sep 2012 17:45:19 -0700
Message-ID: <CANN689Gg9MAzoJ6Yfa0USgD74+Ga+jrecS+a7DaZuMMfKizZPQ@mail.gmail.com>
Subject: Re: [PATCH 2/7] mm: fix potential anon_vma locking issue in mprotect()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, Sep 4, 2012 at 3:16 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> I would suggest to do the strict fix as above in as patch 1/8 and push
> it in -mm, and to do only the optimization removal in 3/8. I think
> we want it in -stable too later, so it'll make life easier to
> cherry-pick the commit if it's merged independently.

All right. So I did this and the strict fix got into Andrew's tree as
mm-fix-potential-anon_vma-locking-issue-in-mprotect.patch

Andrew: when you try applying this series, this patch (2/7) won't
apply due to the strict fix being already there. Please just skip it
(and replace patch 4/7 with the replacement I'm about to send, so that
we end up with the same end state)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
