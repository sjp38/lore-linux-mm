Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3F96B6AA7
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 20:28:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g9-v6so803970pgc.16
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 17:28:25 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e17-v6si14988662pgb.497.2018.09.03.17.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 17:28:24 -0700 (PDT)
Date: Tue, 4 Sep 2018 08:28:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
Message-ID: <20180904002818.nq2ejxlsn4o34anl@wfg-t540p.sh.intel.com>
References: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
 <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Nikita Leshenko <nikita.leshchenko@oracle.com>, akpm@linux-foundation.org, linux-mm@kvack.org, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Christian and Nikita,

On Mon, Sep 03, 2018 at 06:03:49PM +0200, Christian Borntraeger wrote:
>
>
>On 09/03/2018 04:10 PM, Nikita Leshenko wrote:
>> On September 2, 2018 5:21:15 AM, fengguang.wu@intel.com wrote:
>>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>>> index 8b47507faab5..0c483720de8d 100644
>>> --- a/virt/kvm/kvm_main.c
>>> +++ b/virt/kvm/kvm_main.c
>>> @@ -3892,6 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
>>>  	if (type == KVM_EVENT_CREATE_VM) {
>>>  		add_uevent_var(env, "EVENT=create");
>>>  		kvm->userspace_pid = task_pid_nr(current);
>>> +		current->kvm = kvm;
>>
>> Is it OK to store `kvm` on the task_struct? What if the thread that
>> originally created the VM exits? From the documentation it seems
>> like a VM is associated with an address space and not a specific
>> thread, so maybe it should be stored on mm_struct?
>
>Yes, ioctls accessing the kvm can happen from all threads.

Good point, thank you for the tips! I'll move kvm pointer to mm_struct.

>> From Documentation/virtual/kvm/api.txt:
>>    Only run VM ioctls from the same process (address space) that was used
>>    to create the VM.
>>
>> -Nikita

Regards,
Fengguang
