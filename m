Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 652C26B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 13:46:10 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id b205so123350541wmb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:46:10 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id q8si12653112wjz.13.2016.02.16.10.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 10:46:09 -0800 (PST)
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 16 Feb 2016 18:46:08 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5EB0517D8042
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 18:46:23 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1GIk5Iq2097420
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 18:46:05 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1GIk4o0000401
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:46:05 -0700
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name> <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160212231510.GB15142@node.shutemov.name>
 <alpine.LFD.2.20.1602131238260.1910@schleppi>
 <20160215113159.GA28832@node.shutemov.name>
 <20160215193702.4a15ed5e@thinkpad> <20160215213526.GA9766@node.shutemov.name>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56C36E6B.70009@de.ibm.com>
Date: Tue, 16 Feb 2016 19:46:03 +0100
MIME-Version: 1.0
In-Reply-To: <20160215213526.GA9766@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On 02/15/2016 10:35 PM, Kirill A. Shutemov wrote:
> 
> Is there any chance that I'll be able to trigger the bug using QEMU?
> Does anybody have an QEMU image I can use?

qemu/TCG on s390 does neither provide SMP nor large pages (only QEMU/KVM does)
so this will probably not help you here. 

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
