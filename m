Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 312D96B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 05:56:03 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so25325504wib.1
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 02:56:02 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id x18si64155266wiv.98.2014.12.30.02.56.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 02:56:02 -0800 (PST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 30 Dec 2014 10:56:01 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 571802190045
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 10:55:29 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sBUAu0f458458114
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 10:56:00 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sBU5qOOH000571
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 00:52:25 -0500
Date: Tue, 30 Dec 2014 11:55:56 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 30/38] s390: drop pte_file()-related helpers
Message-ID: <20141230115556.1a8b1a94@mschwide>
In-Reply-To: <20141229103757.GA379@node.dhcp.inet.fi>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1419423766-114457-31-git-send-email-kirill.shutemov@linux.intel.com>
	<20141229110727.75afa56d@mschwide>
	<20141229103757.GA379@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, 29 Dec 2014 12:37:57 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Dec 29, 2014 at 11:07:27AM +0100, Martin Schwidefsky wrote:
> > On Wed, 24 Dec 2014 14:22:38 +0200
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > We've replaced remap_file_pages(2) implementation with emulation.
> > > Nobody creates non-linear mapping anymore.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > > ---
> > > @@ -279,7 +279,6 @@ static inline int is_module_addr(void *addr)
> > >   *
> > >   * pte_present is true for the bit pattern .xx...xxxxx1, (pte & 0x001) == 0x001
> > >   * pte_none    is true for the bit pattern .10...xxxx00, (pte & 0x603) == 0x400
> > > - * pte_file    is true for the bit pattern .11...xxxxx0, (pte & 0x601) == 0x600
> > >   * pte_swap    is true for the bit pattern .10...xxxx10, (pte & 0x603) == 0x402
> > >   */
> >  
> > Nice, once this is upstream I can free up one of the software bits in
> > the pte by redefining the type bits. Right now all of them are used up.
> > Is the removal of non-linear mappings a done deal ?
> 
> Yes, if no horrible regression will be reported. We don't create
> non-linear mapping in -mm (and -next) tree for a few release cycles.
> Nobody complained so far.
> 
> Ack?

Yes, ack! 


-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
