Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBCC6B025E
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:16:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z99so530320wrc.15
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:16:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a134si8527367wmd.9.2017.10.18.04.16.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 04:16:54 -0700 (PDT)
Subject: Re: KASAN: use-after-free Read in do_get_mempolicy
References: <CAGHG8Fcnzck+_uOW7rQHBKM4bkC+b2KGBzDPKmMyqp5LQ5t+qQ@mail.gmail.com>
 <CACT4Y+Yx+e+cKiQ7dvXAC-=TeFHGdZGsqE6grgiZEY-sC_e4+w@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e08d4c87-1cc7-ea09-3459-e0d03a920519@suse.cz>
Date: Wed, 18 Oct 2017 13:16:52 +0200
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Yx+e+cKiQ7dvXAC-=TeFHGdZGsqE6grgiZEY-sC_e4+w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Chase Bertke <ceb2817@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/17/2017 05:55 PM, Dmitry Vyukov wrote:
> On Tue, Oct 17, 2017 at 5:38 PM, Chase Bertke <ceb2817@gmail.com> wrote:
>> Hello,
>>
>> I would like to report a bug found via syzkaller on version 4.13.0-rc4. I
>> have searched the syzkaller mailing list and did not see any other reports
>> for this bug.
>>
>> Please see below:
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in do_get_mempolicy+0x1d4/0x740
>> Read of size 8 at addr ffff88006d32fb28 by task syz-executor0/1422
>>
>> CPU: 0 PID: 1422 Comm: syz-executor0 Not tainted 4.13.0-rc4+ #0

Most likely already fixed by 73223e4e2e38 ("mm/mempolicy: fix use after
free when calling get_mempolicy") which landed in v4.13-rc6.

Please focus the fuzzing the latest 4.14-rcX instead :)

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
