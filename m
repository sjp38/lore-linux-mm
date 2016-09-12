Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF6806B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:27:08 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu12so46778603pac.1
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 22:27:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q7si19735966pax.43.2016.09.11.22.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 22:27:08 -0700 (PDT)
Date: Sun, 11 Sep 2016 22:27:03 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160912052703.GA1897@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160908225636.GB15167@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 08, 2016 at 04:56:36PM -0600, Ross Zwisler wrote:
> I think this goes back to our previous discussion about support for the PMEM
> programming model.  Really I think what NVML needs isn't a way to tell if it
> is getting a DAX mapping, but whether it is getting a DAX mapping on a
> filesystem that fully supports the PMEM programming model.  This of course is
> defined to be a filesystem where it can do all of its flushes from userspace
> safely and never call fsync/msync, and that allocations that happen in page
> faults will be synchronized to media before the page fault completes.

That's a an easy way to flag:  you will never get that from a Linux
filesystem, period.

NVML folks really need to stop taking crack and dreaming this could
happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
