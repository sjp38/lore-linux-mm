Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D76966B0011
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:43:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j12so1902493pff.18
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:43:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r22sor861610pfd.16.2018.03.14.10.43.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 10:43:42 -0700 (PDT)
Subject: Re: [PATCH 4/8] struct page: add field for vm_struct
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-5-igor.stoppa@huawei.com>
 <20180313220040.GA15791@bombadil.infradead.org>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <7b18521c-539b-2ba1-823e-e83be071c13f@gmail.com>
Date: Wed, 14 Mar 2018 10:43:37 -0700
MIME-Version: 1.0
In-Reply-To: <20180313220040.GA15791@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 3/13/18 3:00 PM, Matthew Wilcox wrote:
> On Tue, Mar 13, 2018 at 11:45:50PM +0200, Igor Stoppa wrote:
>> When a page is used for virtual memory, it is often necessary to obtain
>> a handler to the corresponding vm_struct, which refers to the virtually
>> continuous area generated when invoking vmalloc.
>>
>> The struct page has a "mapping" field, which can be re-used, to store a
>> pointer to the parent area.
>>
>> This will avoid more expensive searches, later on.
>>
>> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

Igor, do you mind sticking these tags on the files that have spent some 
time reviewing a revision of your patchset (like the Reviewed-by: tags I 
provided last revision?)

Thanks,
Jay
