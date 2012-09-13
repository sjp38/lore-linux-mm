Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 3B7806B017C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 18:46:31 -0400 (EDT)
Received: by iec9 with SMTP id 9so7324065iec.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:46:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50522275.7090709@suse.cz>
References: <50522275.7090709@suse.cz>
Date: Thu, 13 Sep 2012 15:46:30 -0700
Message-ID: <CANN689E0SaT9vaBb+snwYrP728GjZhRj7o7T4GoNfQVY7sBr7Q@mail.gmail.com>
Subject: Re: BUG at mm/huge_memory.c:1428!
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Jiri Slaby <jirislaby@gmail.com>

On Thu, Sep 13, 2012 at 11:14 AM, Jiri Slaby <jslaby@suse.cz> wrote:
> Hi,
>
> I've just get the following BUG with today's -next. It happens every
> time I try to update packages.
>
> kernel BUG at mm/huge_memory.c:1428!

That is very likely my bug.

Do you have the message that should be printed right above the bug ?
(                printk(KERN_ERR "mapcount %d page_mapcount %d\n",
                       mapcount, page_mapcount(page));
)

Do you get any errors if building with CONFIG_DEBUG_VM and CONFIG_DEBUG_VM_RB ?

Does it go away if you revert "mm: avoid taking rmap locks in
move_ptes()" (cc0eac2e50f036d4d798b18679ca2ae3c4828105 in the -next
version I have here) ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
