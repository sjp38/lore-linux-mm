Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 019006B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:52:21 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so49343151pfb.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 07:52:20 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 66si20675654pfs.142.2016.02.12.07.52.20
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 07:52:20 -0800 (PST)
Date: Fri, 12 Feb 2016 15:52:22 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160212155221.GP25087@arm.com>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212100137.GE25087@arm.com>
 <alpine.LFD.2.20.1602121106140.1773@schleppi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1602121106140.1773@schleppi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Feb 12, 2016 at 11:12:34AM +0100, Sebastian Ott wrote:
> On Fri, 12 Feb 2016, Will Deacon wrote:
> > On Thu, Feb 11, 2016 at 08:57:02PM +0100, Gerald Schaefer wrote:
> > > On Thu, 11 Feb 2016 21:09:42 +0200
> > > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > > > On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> > > > > Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> > > > > he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> > > > > review of the THP rework patches, which cannot be bisected, revealed
> > > > > commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> > > > > (and also similar commits for other archs).

[...]

> > Do you have a reliable way to trigger the "random kernel crashes"? We've not
> > seen anything reported on arm64, but I don't see why we wouldn't be affected
> > by the same bug and it would be good to confirm and validate a fix.
> 
> My testcase was compiling the kernel. Most of the time my test system
> didn't survive a single compile run. During bisect I did at least 20
> compile runs to flag a commit as good.

I've been building kernels all day with -rc3 on my arm64 box and haven't
seen any problems yet.. :/.

I'll leave it going over the weekend.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
