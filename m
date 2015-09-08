Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 612C06B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 08:28:36 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so81568871obb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 05:28:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id km1si5279664pab.52.2015.09.08.05.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 05:28:35 -0700 (PDT)
Date: Tue, 8 Sep 2015 13:28:26 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [Qemu-devel] [PATCH 19/23] userfaultfd: activate syscall
Message-ID: <20150908122826.GJ2246@work-vm>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-20-git-send-email-aarcange@redhat.com>
 <20150811100728.GB4587@in.ibm.com>
 <20150811134826.GI4520@redhat.com>
 <20150812052346.GC4587@in.ibm.com>
 <1441692486.14597.17.camel@ellerman.id.au>
 <20150908063948.GB678@in.ibm.com>
 <1441696463.4689.1.camel@ellerman.id.au>
 <1441708821.13127.0.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441708821.13127.0.camel@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: bharata@linux.vnet.ibm.com, kvm@vger.kernel.org, qemu-devel@nongnu.org, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andres Lagar-Cavilla <andreslc@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Johannes Weiner <hannes@cmpxchg.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

* Michael Ellerman (mpe@ellerman.id.au) wrote:
> On Tue, 2015-09-08 at 17:14 +1000, Michael Ellerman wrote:
> > On Tue, 2015-09-08 at 12:09 +0530, Bharata B Rao wrote:
> > > On Tue, Sep 08, 2015 at 04:08:06PM +1000, Michael Ellerman wrote:
> > > > Hmm, not for me. See below.
> > > > 
> > > > What setup were you testing on Bharata?
> > > 
> > > I was on commit a94572f5799dd of userfault21 branch in Andrea's tree
> > > git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
> > > 
> > > #uname -a
> > > Linux 4.1.0-rc8+ #1 SMP Tue Aug 11 11:33:50 IST 2015 ppc64le ppc64le ppc64le GNU/Linux
> > > 
> > > In fact I had successfully done postcopy migration of sPAPR guest with
> > > this setup.
> > 
> > OK, do you mind testing mainline with the same setup to see if the selftest
> > passes.
> 
> Ah, I just tried it on big endian and it works. So it seems to not work on
> little endian for some reason, /probably/ a test case bug?

Hmm; I think we're missing a test-case fix that Andrea made me for a bug I hit on Power
I hit a couple of weeks back.  I think that would have been on le.

Dave

> cheers
> 
> 
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
