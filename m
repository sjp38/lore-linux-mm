Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A658A6B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 10:54:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u70so14952873pfa.2
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 07:54:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si1783877pln.20.2017.10.31.07.54.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 07:54:41 -0700 (PDT)
Subject: Re: possible deadlock in __synchronize_srcu
References: <001a114a6b20cafb9c055cd73f86@google.com>
 <CACT4Y+aCV2wEP2yAh7qDtmuTt55DMEQGXzumxR6iXqitjuruiw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2abff35f-8b06-ff69-0ab1-82f7ea9bb2bd@suse.cz>
Date: Tue, 31 Oct 2017 15:54:38 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aCV2wEP2yAh7qDtmuTt55DMEQGXzumxR6iXqitjuruiw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+b8ff4d5c3fa77f2e2f0f9be34e6b2795ffc3c65e@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, kasan-dev <kasan-dev@googlegroups.com>

On 10/31/2017 02:20 PM, Dmitry Vyukov wrote:
> On Tue, Oct 31, 2017 at 3:54 PM, syzbot
> <bot+b8ff4d5c3fa77f2e2f0f9be34e6b2795ffc3c65e@syzkaller.appspotmail.com>
> wrote:
>> Hello,
>>
>> syzkaller hit the following crash on
>> 9506597de2cde02d48c11d5c250250b9143f59f7

That's next-20170824. Why test/report such old next trees now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
