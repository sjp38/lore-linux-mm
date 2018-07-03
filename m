Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE96F6B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 09:48:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g16-v6so971412edq.10
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 06:48:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p7-v6si1106937edr.357.2018.07.03.06.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 06:48:05 -0700 (PDT)
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1561585c-7d4d-da4a-e9f9-948198eaa562@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <727ecac4-7745-a933-455d-8997656611d3@suse.cz>
Date: Tue, 3 Jul 2018 15:48:01 +0200
MIME-Version: 1.0
In-Reply-To: <1561585c-7d4d-da4a-e9f9-948198eaa562@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On 07/03/2018 03:11 AM, Waiman Long wrote:
> On 07/03/2018 05:18 AM, Andrew Morton wrote:
>> On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>>
>>> On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com> wrote:
>>>> A rogue application can potentially create a large number of negative
>>>> dentries in the system consuming most of the memory available if it
>>>> is not under the direct control of a memory controller that enforce
>>>> kernel memory limit.
>>> I certainly don't mind the patch series, but I would like it to be
>>> accompanied with some actual example numbers, just to make it all a
>>> bit more concrete.
>>>
>>> Maybe even performance numbers showing "look, I've filled the dentry
>>> lists with nasty negative dentries, now it's all slower because we
>>> walk those less interesting entries".
>>>
>> (Please cc linux-mm@kvack.org on this work)
>>
>> Yup.  The description of the user-visible impact of current behavior is
>> far too vague.
>>
>> In the [5/6] changelog it is mentioned that a large number of -ve
>> dentries can lead to oom-killings.  This sounds bad - -ve dentries
>> should be trivially reclaimable and we shouldn't be oom-killing in such
>> a situation.
> 
> The OOM situation was observed in an older distro kernel. It may not be
> the case with the upstream kernel. I will double check that.

Note that dentries with externally allocated (long) names might have
been the factor here, until recent commits f1782c9bc547 ("dcache:
account external names as indirectly reclaimable memory") and
d79f7aa496fc ("mm: treat indirectly reclaimable memory as free in
overcommit logic").

Vlastimil

> Cheers,
> Longman
> 
