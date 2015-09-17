Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 44DF66B0256
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:37:37 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so11449271lbb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:37:36 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id k14si4845269wjr.21.2015.09.17.08.37.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 08:37:35 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so124256607wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:37:35 -0700 (PDT)
Date: Thu, 17 Sep 2015 18:37:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
 VMAs have ->vm_ops set")
Message-ID: <20150917153733.GA31823@node.dhcp.inet.fi>
References: <20150914105346.GB23878@arm.com>
 <20150914115800.06242CE@black.fi.intel.com>
 <20150914170547.GA28535@redhat.com>
 <20150914182033.GA4165@node.dhcp.inet.fi>
 <20150915121201.GA10104@redhat.com>
 <20150915134216.GA16093@node.dhcp.inet.fi>
 <20150916142818.d0e5c01f0e91c91f9959ad84@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150916142818.d0e5c01f0e91c91f9959ad84@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 16, 2015 at 02:28:18PM -0700, Andrew Morton wrote:
> On Tue, 15 Sep 2015 16:42:16 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > I would rather like to see consolidated fault path between file and anon
> > with ->vm_ops set for both. So vma_is_anonymous() will be trivial
> > vma->vm_ops == anon_vm_ops.
> 
> People are noticing: https://bugzilla.kernel.org/show_bug.cgi?id=104691
> 
> How about I send Linus a revert of 6dc296e7df4c while we work out what
> to do?

I think it's the best step for now. Although, I'm not sure when I will get
time on reworking fault path :-/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
