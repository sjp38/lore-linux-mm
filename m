Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB346B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 11:38:50 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b205so74888762wmb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 08:38:50 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id c2si26426517wma.96.2016.02.15.08.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Feb 2016 08:38:49 -0800 (PST)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Mon, 15 Feb 2016 16:38:48 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 32CA017D805D
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 16:39:03 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1FGcjFo393570
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 16:38:45 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1FGciBr023043
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 11:38:45 -0500
Date: Mon, 15 Feb 2016 17:38:43 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
In-Reply-To: <20160215113159.GA28832@node.shutemov.name>
Message-ID: <alpine.LFD.2.20.1602151736120.1820@schleppi>
References: <20160211192223.4b517057@thinkpad> <20160211190942.GA10244@node.shutemov.name> <20160211205702.24f0d17a@thinkpad> <20160212154116.GA15142@node.shutemov.name> <56BE00E7.1010303@de.ibm.com> <20160212181640.4eabb85f@thinkpad>
 <20160212231510.GB15142@node.shutemov.name> <alpine.LFD.2.20.1602131238260.1910@schleppi> <20160215113159.GA28832@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Mon, 15 Feb 2016, Kirill A. Shutemov wrote:
> > [   59.851421] list_del corruption. next->prev should be 000000006e1eb000, but was 0000000000000400
> 
> This kinda interesting: 0x400 is TAIL_MAPPING.. Hm..
> 
> Could you check if you see the problem on commit 1c290f642101 and its
> immediate parent?

Both 1c290f642101 and 1c290f642101^ survived 20 compile runs each.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
