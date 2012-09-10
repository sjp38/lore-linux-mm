Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 0B2746B0062
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 13:41:09 -0400 (EDT)
Received: by iagk10 with SMTP id k10so2603525iag.14
        for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:41:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGDaZ_rBMadBmpPTpoV1vvkfmdf-sRt-9q_o_9jyFuiSJ3ve5w@mail.gmail.com>
References: <5038E7AA.5030107@gmail.com> <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
 <504CCECF.9020104@redhat.com> <CAGDaZ_pLTR3FZy4-txF7ZhMy60xp_BB=-JORd8OhcGcJOG6YCw@mail.gmail.com>
 <k2kqcp$a12$1@ger.gmane.org> <CAGDaZ_rBMadBmpPTpoV1vvkfmdf-sRt-9q_o_9jyFuiSJ3ve5w@mail.gmail.com>
From: Shentino <shentino@gmail.com>
Date: Mon, 10 Sep 2012 10:40:28 -0700
Message-ID: <CAGDaZ_peCVb_8JOVByHH5iUF6upVPVaYw3XR=+fFGkF=k6wGXQ@mail.gmail.com>
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with swappiness==0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, stable@vger.kernel.org

On Mon, Sep 10, 2012 at 10:07 AM, Shentino <shentino@gmail.com> wrote:
> On Mon, Sep 10, 2012 at 6:36 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Sun, 09 Sep 2012 at 18:03 GMT, Shentino <shentino@gmail.com> wrote:
>>>
>>> Just curious, but what theoretically would happen if someone were to
>>> want to set swappiness to 200 or something?
>>>
>>> Should it be sorta like vfs_cache_pressure?
>>>
>>
>>
>> How could it be set to 200? As 0~100 is valid:
>>
>>         {
>>                         .procname       = "swappiness",
>>                         .data           = &vm_swappiness,
>>                         .maxlen         = sizeof(vm_swappiness),
>>                         .mode           = 0644,
>>                         .proc_handler   = proc_dointvec_minmax,
>>                         .extra1         = &zero,
>>                         .extra2         = &one_hundred,
>>         },
>
> My comment/question was more abstract and focusing on the comparison
> to vfs_cache_pressure.

Just to be clear about what I meant.

Both swapping and reclaiming from dentry/inode caches both share the
common factor of being alternatives to reclaiming from page cache when
memory is tight.

So I was wondering how similiar in effect these two knobs should be.

One possible use case off the top of my head is a file server that
banks heavily on page cache and spends most of its runtime sending
file data over the network.  It might be overkill but swappiness > 100
might actually be beneficial here.  I have no numbers to back it up
though as it's a rough idea.

Sorry if I'm butting in on the subject but I was curious about the idea.

Also still learning how to pos tin general on the kernel lists, so
apologies if I've been rude or anything.

>
> :P
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
