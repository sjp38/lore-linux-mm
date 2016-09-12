Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBFCA6B0253
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:01:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so72396101pac.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:01:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id p75si1292599pfd.106.2016.09.12.08.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 08:01:56 -0700 (PDT)
Date: Mon, 12 Sep 2016 08:01:48 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160912150148.GA10039@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <20160912052703.GA1897@infradead.org>
 <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
 <20160912075128.GB21474@infradead.org>
 <20160912180507.533b3549@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160912180507.533b3549@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Mon, Sep 12, 2016 at 06:05:07PM +1000, Nicholas Piggin wrote:
> It's not fundamentally broken, it just doesn't fit well existing
> filesystems.

Or the existing file system architecture for that matter.  Which makes
it a fundamentally broken model.

> Dave's post of requirements is also wrong. A filesystem does not have
> to guarantee all that, it only has to guarantee that is the case for
> a given block after it has a mapping and page fault returns, other
> operations can be supported by invalidating mappings, etc.

Which doesn't really matter if your use case is manipulating
fully mapped files.

But back to the point: if you want to use a full blown Linux or Unix
filesystem you will always have to fsync (or variants of it like msync),
period.

If you want a volume manager on stereoids that hands out large chunks
of storage memory that can't ever be moved, truncated, shared, allocated
on demand, etc - implement it in your library on top of a device file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
