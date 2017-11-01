Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8487F28025D
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 12:17:06 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o74so8903522iod.15
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 09:17:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e201sor539933itc.23.2017.11.01.09.17.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 09:17:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2abff35f-8b06-ff69-0ab1-82f7ea9bb2bd@suse.cz>
References: <001a114a6b20cafb9c055cd73f86@google.com> <CACT4Y+aCV2wEP2yAh7qDtmuTt55DMEQGXzumxR6iXqitjuruiw@mail.gmail.com>
 <2abff35f-8b06-ff69-0ab1-82f7ea9bb2bd@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Nov 2017 19:16:44 +0300
Message-ID: <CACT4Y+YJLajoyaU83FHf-6EinhQuaEpkCYwisyPxe=aScygQKg@mail.gmail.com>
Subject: Re: possible deadlock in __synchronize_srcu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <bot+b8ff4d5c3fa77f2e2f0f9be34e6b2795ffc3c65e@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, kasan-dev <kasan-dev@googlegroups.com>

On Tue, Oct 31, 2017 at 5:54 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 10/31/2017 02:20 PM, Dmitry Vyukov wrote:
>> On Tue, Oct 31, 2017 at 3:54 PM, syzbot
>> <bot+b8ff4d5c3fa77f2e2f0f9be34e6b2795ffc3c65e@syzkaller.appspotmail.com>
>> wrote:
>>> Hello,
>>>
>>> syzkaller hit the following crash on
>>> 9506597de2cde02d48c11d5c250250b9143f59f7
>
> That's next-20170824. Why test/report such old next trees now?


That's just a side effect of the fact that we started testing and
collecting crashes before we had all infrastructure to pipe bugs to
kernel mailing lists. So we ended up with a bug jam and now trying to
drain it. Some of the old bugs indeed ended up being fixed meanwhile.
But we reported the ones that are still relevant. Once we drain the
jam, we will start reporting fresh bugs. We are always testing the
latest revisions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
