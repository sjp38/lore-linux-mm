Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3D66B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 09:16:06 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id a4so72691039wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:16:06 -0800 (PST)
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com. [195.75.94.104])
        by mx.google.com with ESMTPS id t82si12977852wmg.117.2016.02.19.06.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 06:16:05 -0800 (PST)
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Fri, 19 Feb 2016 14:16:04 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id E484317D8042
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 14:16:10 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1JEFppF14024874
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 14:15:51 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1JEFoX4026541
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 07:15:51 -0700
Date: Fri, 19 Feb 2016 15:15:50 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
In-Reply-To: <20160218170658.GC28184@node.shutemov.name>
Message-ID: <alpine.LFD.2.20.1602191509270.1742@schleppi>
References: <20160211190942.GA10244@node.shutemov.name> <20160211205702.24f0d17a@thinkpad> <20160212154116.GA15142@node.shutemov.name> <56BE00E7.1010303@de.ibm.com> <20160212181640.4eabb85f@thinkpad> <20160212231510.GB15142@node.shutemov.name>
 <alpine.LFD.2.20.1602131238260.1910@schleppi> <20160217201340.2dafad8d@thinkpad> <20160217235808.GA21696@node.shutemov.name> <20160218160037.627cc7ec@thinkpad> <20160218170658.GC28184@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org


On Thu, 18 Feb 2016, Kirill A. Shutemov wrote:
> I worth minimizing kernel config on which you can see the bug. Things like
> CONFIG_DEBUG_PAGEALLOC used to interfere with THP before.

I disabled all debugging options (using
arch/s390/configs/performance_defconfig) - we still chrashed.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
