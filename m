Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A6C436B0062
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 11:39:35 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so2719068bkc.14
        for <linux-mm@kvack.org>; Mon, 17 Sep 2012 08:39:33 -0700 (PDT)
Message-ID: <50574432.5040005@suse.cz>
Date: Mon, 17 Sep 2012 17:39:30 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: BUG at mm/huge_memory.c:1428!
References: <50522275.7090709@suse.cz> <CANN689E0SaT9vaBb+snwYrP728GjZhRj7o7T4GoNfQVY7sBr7Q@mail.gmail.com> <50538561.8030505@suse.cz>
In-Reply-To: <50538561.8030505@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Jiri Slaby <jirislaby@gmail.com>

On 09/14/2012 09:28 PM, Jiri Slaby wrote:
> On 09/14/2012 12:46 AM, Michel Lespinasse wrote:
>> On Thu, Sep 13, 2012 at 11:14 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>>> Hi,
>>>
>>> I've just get the following BUG with today's -next. It happens every
>>> time I try to update packages.
>>>
>>> kernel BUG at mm/huge_memory.c:1428!
>>
>> That is very likely my bug.
>>
>> Do you have the message that should be printed right above the bug ?
>> (                printk(KERN_ERR "mapcount %d page_mapcount %d\n",
>>                        mapcount, page_mapcount(page));
>> )
> 
> Unfortunately no. And I cannot reproduce anymore :(...

FWIW: mapcount 0 page_mapcount 1

It happened today. Now I'm going to apply your patch.

> thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
