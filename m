Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACE66B003A
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 18:36:55 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id tr6so8033144ieb.41
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 15:36:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id vf6si2745929igb.55.2014.09.11.15.36.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 15:36:54 -0700 (PDT)
Message-ID: <541223F9.2090500@oracle.com>
Date: Thu, 11 Sep 2014 18:36:41 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: introduce VM_BUG_ON_MM
References: <1410032326-4380-1-git-send-email-sasha.levin@oracle.com>	<1410032326-4380-2-git-send-email-sasha.levin@oracle.com> <20140911141629.e24f7fa5a2ec2401d4f3b429@linux-foundation.org>
In-Reply-To: <20140911141629.e24f7fa5a2ec2401d4f3b429@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/11/2014 05:16 PM, Andrew Morton wrote:
> On Sat,  6 Sep 2014 15:38:45 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> Very similar to VM_BUG_ON_PAGE and VM_BUG_ON_VMA, dump struct_mm
>> when the bug is hit.
>>
>> ...
>>
>> +void dump_mm(const struct mm_struct *mm)
>> +{
>> +	printk(KERN_ALERT
> 
> I'm not sure why we should use KERN_ALERT here - KERN_EMERG is for
> "system is unusable", which is a fair descrition of a post-BUG kernel,
> yes?

Yes. I was following suit with dump_page and assumed there's a good reasoning
behind KERN_ALERT.

>> +		"mm %p mmap %p seqnum %d task_size %lu\n"
>> +#ifdef CONFIG_MMU
>> +		"get_unmapped_area %p\n"
>> +#endif
> 
> This printk is rather hilarious.  I can't think of a better way apart
> from a great string of individual printks.
> 
> And maybe we should use individual printks - dump_mm() presently uses
> 114 bytes of stack for that printk and that's somewhat of a concern
> considering the situations when it will be called.
> 
> 
> How's this look?

Works for me.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
