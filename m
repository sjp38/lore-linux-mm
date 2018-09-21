Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17D508E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 14:17:27 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j5-v6so12727579oiw.13
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:17:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w131-v6sor18538664oig.152.2018.09.21.11.17.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 11:17:25 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
 <4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
 <fefbd66e-623d-b6a5-7202-5309dd4f5b32@redhat.com> <20180920224953.GA53363@tiger-server>
 <CAPcyv4g6OS=_uSjJenn5WVmpx7zCRCbzJaBr_m0Bq=qyEyVagg@mail.gmail.com>
 <20180921224739.GA33892@tiger-server> <c8ad8ed7-ca8c-4dd7-819b-8d9c856fbe04@redhat.com>
In-Reply-To: <c8ad8ed7-ca8c-4dd7-819b-8d9c856fbe04@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 21 Sep 2018 11:17:13 -0700
Message-ID: <CAPcyv4j9K-wkq8oK-8_twWViKhyGSHD7cOE5UoRN-09xKXPq7A@mail.gmail.com>
Subject: Re: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>

On Fri, Sep 21, 2018 at 7:24 AM David Hildenbrand <david@redhat.com> wrote:
[..]
> > Remove the PageReserved flag sounds more reasonable.
> > And Could we still have a flag to identify it is a device private memory, or
> > where these pages coming from?
>
> We could use a page type for that or what you proposed. (as I said, we
> might have to change hibernation code to skip the pages once we drop the
> reserved flag).

I think it would be reasonable to reject all ZONE_DEVICE pages in
saveable_page().
