Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0E476B06CD
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 11:08:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k71so2362864wrc.15
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 08:08:42 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y35si1700857wrc.190.2017.08.03.08.08.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 08:08:41 -0700 (PDT)
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
References: <07063abd-2f5d-20d9-a182-8ae9ead26c3c@huawei.com>
 <20170802170848.GA3240@redhat.com>
 <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
 <20170803114844.GO12521@dhcp22.suse.cz>
 <c3a250a6-ad4d-d24d-d0bf-4c43c467ebe6@huawei.com>
 <20170803135549.GW12521@dhcp22.suse.cz> <20170803144746.GA9501@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <ab4809cd-0efc-a79d-6852-4bd2349a2b3f@huawei.com>
Date: Thu, 3 Aug 2017 18:06:11 +0300
MIME-Version: 1.0
In-Reply-To: <20170803144746.GA9501@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>



On 03/08/17 17:47, Jerome Glisse wrote:
> On Thu, Aug 03, 2017 at 03:55:50PM +0200, Michal Hocko wrote:
>> On Thu 03-08-17 15:20:31, Igor Stoppa wrote:

[...]

>>> I am confused about this: if "private2" is a pointer, but when I get an
>>> address, I do not even know if the address represents a valid pmalloc
>>> page, how can i know when it's ok to dereference "private2"?
>>
>> because you can make all pages which back vmalloc mappings have vm_area
>> pointer set.
> 
> Note that i think this might break some device driver that use vmap()
> i think some of them use private field to store device driver specific
> informations. But there likely is an unuse field in struct page that
> can be use for that.

This increases the unease from my side ... it looks like there is no way
to fully understand if a field is really used or not, without having
deep intimate knowledge of lots of code that is only marginally involved :-/

Similarly, how would I be able to specify what would be the correct way
to decide the member of the union to use for handling the field?

If there were either some sort of non-multiplexed tag/cookie field or a
function, that would specify how to treat the various unions, then it
would be easier to multiplex the remaining data, according to how the
page is used.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
