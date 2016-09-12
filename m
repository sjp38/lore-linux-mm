Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7041F6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:05:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so53048738pac.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:05:20 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id ta8si20477452pab.231.2016.09.12.01.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 01:05:19 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 128so7744432pfb.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:05:19 -0700 (PDT)
Date: Mon, 12 Sep 2016 18:05:07 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160912180507.533b3549@roar.ozlabs.ibm.com>
In-Reply-To: <20160912075128.GB21474@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
	<20160908225636.GB15167@linux.intel.com>
	<20160912052703.GA1897@infradead.org>
	<CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
	<20160912075128.GB21474@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Mon, 12 Sep 2016 00:51:28 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Sep 12, 2016 at 05:25:15PM +1000, Oliver O'Halloran wrote:
> > What are the problems here? Is this a matter of existing filesystems
> > being unable/unwilling to support this or is it just fundamentally
> > broken?  
> 
> It's a fundamentally broken model.  See Dave's post that actually was
> sent slightly earlier then mine for the list of required items, which
> is fairly unrealistic.  You could probably try to architect a file
> system for it, but I doubt it would gain much traction.

It's not fundamentally broken, it just doesn't fit well existing
filesystems.

Dave's post of requirements is also wrong. A filesystem does not have
to guarantee all that, it only has to guarantee that is the case for
a given block after it has a mapping and page fault returns, other
operations can be supported by invalidating mappings, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
