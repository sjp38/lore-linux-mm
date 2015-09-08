Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB6B6B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 06:40:27 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so70656821igc.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 03:40:27 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id v11si4774052pdi.230.2015.09.08.03.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 03:40:26 -0700 (PDT)
Message-ID: <1441708821.13127.0.camel@ellerman.id.au>
Subject: Re: [Qemu-devel] [PATCH 19/23] userfaultfd: activate syscall
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 08 Sep 2015 20:40:21 +1000
In-Reply-To: <1441696463.4689.1.camel@ellerman.id.au>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
	 <1431624680-20153-20-git-send-email-aarcange@redhat.com>
	 <20150811100728.GB4587@in.ibm.com> <20150811134826.GI4520@redhat.com>
	 <20150812052346.GC4587@in.ibm.com>
	 <1441692486.14597.17.camel@ellerman.id.au>
	 <20150908063948.GB678@in.ibm.com> <1441696463.4689.1.camel@ellerman.id.au>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bharata@linux.vnet.ibm.com
Cc: kvm@vger.kernel.org, qemu-devel@nongnu.org, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, "Dr.
 David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Johannes Weiner <hannes@cmpxchg.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

On Tue, 2015-09-08 at 17:14 +1000, Michael Ellerman wrote:
> On Tue, 2015-09-08 at 12:09 +0530, Bharata B Rao wrote:
> > On Tue, Sep 08, 2015 at 04:08:06PM +1000, Michael Ellerman wrote:
> > > Hmm, not for me. See below.
> > > 
> > > What setup were you testing on Bharata?
> > 
> > I was on commit a94572f5799dd of userfault21 branch in Andrea's tree
> > git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
> > 
> > #uname -a
> > Linux 4.1.0-rc8+ #1 SMP Tue Aug 11 11:33:50 IST 2015 ppc64le ppc64le ppc64le GNU/Linux
> > 
> > In fact I had successfully done postcopy migration of sPAPR guest with
> > this setup.
> 
> OK, do you mind testing mainline with the same setup to see if the selftest
> passes.

Ah, I just tried it on big endian and it works. So it seems to not work on
little endian for some reason, /probably/ a test case bug?

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
