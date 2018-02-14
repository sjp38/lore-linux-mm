Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1016B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 16:24:11 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id y11so8484582vkd.11
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:24:11 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id 5si6572277wmf.69.2018.02.14.01.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 01:28:44 -0800 (PST)
Subject: Re: WARNING in kvmalloc_node
References: <001a1144c4ca5dc9d6056520c7b7@google.com>
 <20180214025533.GA28811@bombadil.infradead.org>
 <20180214084308.GX3443@dhcp22.suse.cz>
From: Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <f3fda93e-b223-3c94-3213-43cad4346716@iogearbox.net>
Date: Wed, 14 Feb 2018 10:28:26 +0100
MIME-Version: 1.0
In-Reply-To: <20180214084308.GX3443@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+1a240cdb1f4cc88819df@syzkaller.appspotmail.com>, akpm@linux-foundation.org, dhowells@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, rppt@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, viro@zeniv.linux.org.uk, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, brouer@redhat.com, jasowang@redhat.com

[ +Jason, +Jesper ]

On 02/14/2018 09:43 AM, Michal Hocko wrote:
> On Tue 13-02-18 18:55:33, Matthew Wilcox wrote:
>> On Tue, Feb 13, 2018 at 03:59:01PM -0800, syzbot wrote:
> [...]
>>>  kvmalloc include/linux/mm.h:541 [inline]
>>>  kvmalloc_array include/linux/mm.h:557 [inline]
>>>  __ptr_ring_init_queue_alloc include/linux/ptr_ring.h:474 [inline]
>>>  ptr_ring_init include/linux/ptr_ring.h:492 [inline]
>>>  __cpu_map_entry_alloc kernel/bpf/cpumap.c:359 [inline]
>>>  cpu_map_update_elem+0x3c3/0x8e0 kernel/bpf/cpumap.c:490
>>>  map_update_elem kernel/bpf/syscall.c:698 [inline]
>>
>> Blame the BPF people, not the MM people ;-)

Heh, not really. ;-)

> Yes. kvmalloc (the vmalloc part) doesn't support GFP_ATOMIC semantic.

Agree, that doesn't work.

Bug was added in commit 0bf7800f1799 ("ptr_ring: try vmalloc() when kmalloc() fails").

Jason, please take a look at fixing this, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
