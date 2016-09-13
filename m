Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45BA06B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 01:41:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu12so116384293pac.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 22:41:06 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id xl3si25659841pab.117.2016.09.12.22.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 22:41:00 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id p2so2519999pap.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 22:41:00 -0700 (PDT)
Date: Tue, 13 Sep 2016 15:40:48 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160913154048.76b0e0bc@roar.ozlabs.ibm.com>
In-Reply-To: <CAPcyv4iPh2io4S4LpyFvgn9NcoOUEHU25uBz3aSZPJaxbZJZoA@mail.gmail.com>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
	<20160908225636.GB15167@linux.intel.com>
	<20160912052703.GA1897@infradead.org>
	<CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
	<20160912075128.GB21474@infradead.org>
	<20160912180507.533b3549@roar.ozlabs.ibm.com>
	<20160912150148.GA10039@infradead.org>
	<20160913113128.4eae792e@roar.ozlabs.ibm.com>
	<CAPcyv4iPh2io4S4LpyFvgn9NcoOUEHU25uBz3aSZPJaxbZJZoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, KVM list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 12 Sep 2016 21:06:49 -0700
Dan Williams <dan.j.williams@intel.com> wrote:

> On Mon, Sep 12, 2016 at 6:31 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> > On Mon, 12 Sep 2016 08:01:48 -0700  
> [..]
> > That said, a noop system call is on the order of 100 cycles nowadays,
> > so rushing to implement these APIs without seeing good numbers and
> > actual users ready to go seems premature. *This* is the real reason
> > not to implement new APIs yet.  
> 
> Yes, and harvesting the current crop of low hanging performance fruit
> in the filesystem-DAX I/O path remains on the todo list.
> 
> In the meantime we're pursuing this mm api, mincore+ or whatever we
> end up with, to allow userspace to distinguish memory address ranges
> that are backed by a filesystem requiring coordination of metadata
> updates + flushes for updates, vs something like device-dax that does
> not.

Yes, that's reasonable.

Do you need page/block granularity? Do you need a way to advise/request
the fs for a particular capability? Is it enough to request and check
success? Would the capability be likely to change, and if so, how would
you notify the app asynchronously?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
