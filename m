Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 81E926B005A
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 15:28:37 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so2444713wib.2
        for <linux-mm@kvack.org>; Fri, 14 Sep 2012 12:28:35 -0700 (PDT)
Message-ID: <50538561.8030505@suse.cz>
Date: Fri, 14 Sep 2012 21:28:33 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: BUG at mm/huge_memory.c:1428!
References: <50522275.7090709@suse.cz> <CANN689E0SaT9vaBb+snwYrP728GjZhRj7o7T4GoNfQVY7sBr7Q@mail.gmail.com>
In-Reply-To: <CANN689E0SaT9vaBb+snwYrP728GjZhRj7o7T4GoNfQVY7sBr7Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Jiri Slaby <jirislaby@gmail.com>

On 09/14/2012 12:46 AM, Michel Lespinasse wrote:
> On Thu, Sep 13, 2012 at 11:14 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>> Hi,
>>
>> I've just get the following BUG with today's -next. It happens every
>> time I try to update packages.
>>
>> kernel BUG at mm/huge_memory.c:1428!
> 
> That is very likely my bug.
> 
> Do you have the message that should be printed right above the bug ?
> (                printk(KERN_ERR "mapcount %d page_mapcount %d\n",
>                        mapcount, page_mapcount(page));
> )

Unfortunately no. And I cannot reproduce anymore :(...

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
