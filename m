Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D92F6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 03:25:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t7so191686780qkh.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 00:25:17 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id v4si10398451qkg.52.2016.09.12.00.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 00:25:16 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id b204so1707769qkc.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 00:25:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160912052703.GA1897@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com> <20160912052703.GA1897@infradead.org>
From: "Oliver O'Halloran" <oohall@gmail.com>
Date: Mon, 12 Sep 2016 17:25:15 +1000
Message-ID: <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in /proc/self/smaps)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Sep 12, 2016 at 3:27 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Sep 08, 2016 at 04:56:36PM -0600, Ross Zwisler wrote:
>> I think this goes back to our previous discussion about support for the PMEM
>> programming model.  Really I think what NVML needs isn't a way to tell if it
>> is getting a DAX mapping, but whether it is getting a DAX mapping on a
>> filesystem that fully supports the PMEM programming model.  This of course is
>> defined to be a filesystem where it can do all of its flushes from userspace
>> safely and never call fsync/msync, and that allocations that happen in page
>> faults will be synchronized to media before the page fault completes.
>
> That's a an easy way to flag:  you will never get that from a Linux
> filesystem, period.
>
> NVML folks really need to stop taking crack and dreaming this could
> happen.

Well, that's a bummer.

What are the problems here? Is this a matter of existing filesystems
being unable/unwilling to support this or is it just fundamentally
broken? The end goal is to let applications manage the persistence of
their own data without having to involve the kernel in every IOP, but
if we can't do that then what would a 90% solution look like? I think
most people would be OK with having to do an fsync() occasionally, but
not after ever write to pmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
