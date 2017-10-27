Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC9546B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 07:28:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k7so5500393pga.8
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 04:28:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x66si5231170pfa.407.2017.10.27.04.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 04:28:05 -0700 (PDT)
Subject: Re: possible deadlock in lru_add_drain_all
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4284e00c-8f6d-7c6a-8d46-fa20b074a4b3@suse.cz>
Date: Fri, 27 Oct 2017 13:27:57 +0200
MIME-Version: 1.0
In-Reply-To: <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, jglisse@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, ying.huang@intel.com

On 10/27/2017 11:34 AM, Michal Hocko wrote:
> On Fri 27-10-17 02:22:40, syzbot wrote:
>> Hello,
>>
>> syzkaller hit the following crash on
>> a31cc455c512f3f1dd5f79cac8e29a7c8a617af8
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
> 
> I do not see such a commit. My linux-next top is next-20171018

It's the next-20170911 tag. Try git fetch --tags, but I'm not sure how
many are archived...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
