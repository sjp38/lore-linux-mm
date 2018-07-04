Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C85B26B0289
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:27:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m6-v6so6509167qkd.20
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:27:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p20-v6si70920qtf.42.2018.07.04.08.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 08:27:25 -0700 (PDT)
Subject: Re: [PATCH 3/3] kvm: add a function to check if page is from NVDIMM
 pmem.
References: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
 <359fdf0103b61014bf811d88d4ce36bc793d18f2.1530716899.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4is0T1SjsaC4Z80ND9Q_032_Tsa0hQwkO84T0FCRj5MkA@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <fe420914-212f-a18e-b6ec-f2b7a451c0d2@redhat.com>
Date: Wed, 4 Jul 2018 17:27:17 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4is0T1SjsaC4Z80ND9Q_032_Tsa0hQwkO84T0FCRj5MkA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, "Zhang, Yi Z" <yi.z.zhang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 04/07/2018 16:50, Dan Williams wrote:
>> +       return is_zone_device_page(page) &&
>> +               ((page->pgmap->type == MEMORY_DEVICE_FS_DAX) ||
>> +                (page->pgmap->type == MEMORY_DEVICE_DEV_DAX));
> Jerome, might there be any use case to pass MEMORY_DEVICE_PUBLIC
> memory to a guest vm?
> 

An even better reason to place this in mm.h. :)  There should be an
function to tell you if a reserved page has accessed/dirty bits etc.,
that's all that KVM needs to know.

Paolo
