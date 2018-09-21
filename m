Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE4058E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:29:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a70-v6so13609894qkb.16
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:29:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f2-v6si62579qtl.61.2018.09.21.12.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 12:29:05 -0700 (PDT)
Subject: Re: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
 <4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
 <fefbd66e-623d-b6a5-7202-5309dd4f5b32@redhat.com>
 <20180920224953.GA53363@tiger-server>
 <CAPcyv4g6OS=_uSjJenn5WVmpx7zCRCbzJaBr_m0Bq=qyEyVagg@mail.gmail.com>
 <20180921224739.GA33892@tiger-server>
 <c8ad8ed7-ca8c-4dd7-819b-8d9c856fbe04@redhat.com>
 <CAPcyv4j9K-wkq8oK-8_twWViKhyGSHD7cOE5UoRN-09xKXPq7A@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <159bb198-a4a1-0fee-bf57-24c3c28788bd@redhat.com>
Date: Fri, 21 Sep 2018 21:29:00 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4j9K-wkq8oK-8_twWViKhyGSHD7cOE5UoRN-09xKXPq7A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>

On 21/09/2018 20:17, Dan Williams wrote:
> On Fri, Sep 21, 2018 at 7:24 AM David Hildenbrand <david@redhat.com> wrote:
> [..]
>>> Remove the PageReserved flag sounds more reasonable.
>>> And Could we still have a flag to identify it is a device private memory, or
>>> where these pages coming from?
>>
>> We could use a page type for that or what you proposed. (as I said, we
>> might have to change hibernation code to skip the pages once we drop the
>> reserved flag).
> 
> I think it would be reasonable to reject all ZONE_DEVICE pages in
> saveable_page().
> 

Indeed, that sounds like the easiest solution - guess that answer was
too easy for me to figure out :) .

-- 

Thanks,

David / dhildenb
