Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE4D6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 10:54:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x85so8387108oix.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:54:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o54si124490otc.305.2017.09.25.07.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 07:54:43 -0700 (PDT)
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
 <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
 <fb013ae6-6f47-248b-db8b-a0abae530377@redhat.com>
 <ee87215d-9704-7269-4ec1-226f2e32a751@oracle.com>
 <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
 <20170925123508.pzjbe7wgwagnr5li@dhcp22.suse.cz>
 <e301609c-b2ac-24d1-c349-8d25e5123258@redhat.com>
 <20170925125207.4tu24sbpnihljknu@dhcp22.suse.cz>
 <765cd0cb-aa35-187c-456d-05d8752caa04@redhat.com>
 <20170925145238.gic2n37ffc6ytyvx@dhcp22.suse.cz>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <d06a26f1-5509-bd85-74bc-b08c3db0cb0d@redhat.com>
Date: Mon, 25 Sep 2017 16:54:39 +0200
MIME-Version: 1.0
In-Reply-To: <20170925145238.gic2n37ffc6ytyvx@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

On 09/25/2017 04:52 PM, Michal Hocko wrote:
> On Mon 25-09-17 15:16:09, Florian Weimer wrote:
>> On 09/25/2017 02:52 PM, Michal Hocko wrote:
>>> So, how are you going to deal with the CoW and the implementation which
>>> basically means that the newm mmap content is not the same as the
>>> original one?
>>
>> I don't understand why CoW would kick in.
> 
> So you can guarantee nobody is going to write to that memory?

It's mapped readable and executable, but not writable.  So the only 
thing that could interfere would be a debugger.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
