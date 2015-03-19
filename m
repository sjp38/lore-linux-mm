Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB2D6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 09:24:44 -0400 (EDT)
Received: by lagg8 with SMTP id g8so61979117lag.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 06:24:43 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id uq10si976389lbb.86.2015.03.19.06.24.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 06:24:42 -0700 (PDT)
Message-ID: <550ACE17.9040600@yandex-team.ru>
Date: Thu, 19 Mar 2015 16:24:39 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
References: <20150318083040.7838.76933.stgit@zurg> <20150318095702.GA2479@node.dhcp.inet.fi> <5509644C.40502@yandex-team.ru> <550AC958.9010502@suse.cz>
In-Reply-To: <550AC958.9010502@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 19.03.2015 16:04, Vlastimil Babka wrote:
> On 03/18/2015 12:41 PM, Konstantin Khlebnikov wrote:
>> On 18.03.2015 12:57, Kirill A. Shutemov wrote:
>>>
>>> I don't think it worth it. The only right way to fix the problem is ECC
>>> memory.
>>>
>>
>> ECC seems good protection until somebody figure out how to break it too.
>
> I doubt that kind of attitude can get us very far. If we can't trust the
> hardware, we lose sooner or later.
>

Obviously ECC was designed for protecting against cosmic rays which 
flips several bits. If attacker modifies whole cacheline he can chose
value which have the same ECC. I hope next generation of DRAM (or PRAM)
wouldn't be affected.

Software solution is possible: we can put untrusted applications into
special ghetto memory zone. This is relatively easy for virtual 
machines. And it seems might work for normal tasks too (page-cache
pages should be doubled or handled in the way similar to copy-on-read
from that patch).

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
