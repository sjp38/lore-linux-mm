Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C87376B0269
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:11:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v198-v6so8469400qka.16
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:11:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si50866qke.100.2018.10.25.01.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 01:11:05 -0700 (PDT)
Date: Thu, 25 Oct 2018 16:11:00 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv2 1/2] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181025081100.GA31346@MiWiFi-R3L-srv>
References: <20181024125112.55999-1-kirill.shutemov@linux.intel.com>
 <20181024125112.55999-2-kirill.shutemov@linux.intel.com>
 <20181025021809.GB2120@MiWiFi-R3L-srv>
 <20181025072429.k54aem37sefqonqy@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025072429.k54aem37sefqonqy@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/25/18 at 10:24am, Kirill A. Shutemov wrote:
> On Thu, Oct 25, 2018 at 10:18:09AM +0800, Baoquan He wrote:
> > > We don't touch 4 pgd slot gap just before the direct mapping reserved
> > > for a hypervisor, but move direct mapping by one slot instead.
> > > 
> > > The LDT mapping is per-mm, so we cannot move it into P4D page table next
> > > to CPU_ENTRY_AREA without complicating PGD table allocation for 5-level
> > > paging.
> > 
> > Here as discussed in private thread, at the first place you also agreed
> > to put it in p4d entry next to CPU_ENTRY_AREA, but finally you changd
> > mind, there must be some reasons when you implemented and investigated
> > further to find out. Could you please say more about how it will
> > complicating PGD table allocation for 5-level paging? Or give an use
> > case where it will complicate?
> 
> On 5-level machine all memory starting from CPU_ENTRY_AREA (and part of
> KASAN memory) is in the same P4D page table. All this memory is shared
> across all processes, we just copy PGD entry -- all proceses point to the
> same P4D page table. (I leave out PTI from the picture for simplicity.)

Yes, got it, I didn't notice this, thanks a lot.
