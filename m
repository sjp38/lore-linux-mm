Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9C1A6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:26:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f66so6479436oib.4
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:26:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 66sor476299otl.31.2017.10.13.08.26.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 08:26:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171013094431.GA27308@stefanha-x1.localdomain>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com>
 <20171013094431.GA27308@stefanha-x1.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Oct 2017 08:25:59 -0700
Message-ID: <CAPcyv4itKNqVbisM7aAZKZ02QRwfvy9XBHZYWTjqJqcGEZVguw@mail.gmail.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: Pankaj Gupta <pagupta@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, "Zwisler, Ross" <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>

On Fri, Oct 13, 2017 at 2:44 AM, Stefan Hajnoczi <stefanha@gmail.com> wrote:
> On Thu, Oct 12, 2017 at 09:20:26PM +0530, Pankaj Gupta wrote:
[..]
>> +#ifndef REQ_FLUSH
>> +#define REQ_FLUSH REQ_PREFLUSH
>> +#endif
>
> Is this out-of-tree kernel module compatibility stuff that can be
> removed?

Yes, this was copied from the pmem driver where it can also be
removed, it was used to workaround a merge order problem in linux-next
when these definitions were changed several kernel releases back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
