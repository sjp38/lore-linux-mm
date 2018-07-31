Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 504C56B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 23:07:12 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id g12-v6so4694178ual.13
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:07:12 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q135-v6si5823330vkd.44.2018.07.30.20.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 20:07:10 -0700 (PDT)
Subject: Re: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
References: <20180727211727.5020-1-jane.chu@oracle.com>
 <20180728190248.GA883@bombadil.infradead.org>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <026b057d-ec11-9273-40bc-072a8958bb64@oracle.com>
Date: Mon, 30 Jul 2018 20:06:40 -0700
MIME-Version: 1.0
In-Reply-To: <20180728190248.GA883@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, dave@stgolabs.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

Hi, Mathew,


On 7/28/2018 12:02 PM, Matthew Wilcox wrote:
> On Fri, Jul 27, 2018 at 03:17:27PM -0600, Jane Chu wrote:
>> +++ b/include/linux/mm.h
>> @@ -387,6 +387,13 @@ enum page_entry_size {
>>    * These are the virtual MM functions - opening of an area, closing and
>>    * unmapping it (needed to keep files on disk up-to-date etc), pointer
>>    * to the functions called when a no-page or a wp-page exception occurs.
>> + *
>> + * Note, when a new function is introduced to vm_operations_struct and
>> + * added to hugetlb_vm_ops, please consider adding the function to
>> + * shm_vm_ops. This is because under System V memory model, though
>> + * mappings created via shmget/shmat with "huge page" specified are
>> + * backed by hugetlbfs files, their original vm_ops are overwritten with
>> + * shm_vm_ops.
>>    */
>>   struct vm_operations_struct {
> I don't think this header file is the right place for this comment.
> I'd think a better place for it would be at the definition of hugetlb_vm_ops.

Agreed, will make the change.
Thanks for reviewing!

-jane
