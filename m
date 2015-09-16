Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id D1ADD6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 17:28:20 -0400 (EDT)
Received: by qgt47 with SMTP id 47so183578809qgt.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 14:28:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o88si23826407qkh.75.2015.09.16.14.28.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 14:28:20 -0700 (PDT)
Date: Wed, 16 Sep 2015 14:28:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: LTP regressions due to 6dc296e7df4c
 ("mm: make sure all file VMAs have ->vm_ops set")
Message-Id: <20150916142818.d0e5c01f0e91c91f9959ad84@linux-foundation.org>
In-Reply-To: <20150915134216.GA16093@node.dhcp.inet.fi>
References: <20150914105346.GB23878@arm.com>
	<20150914115800.06242CE@black.fi.intel.com>
	<20150914170547.GA28535@redhat.com>
	<20150914182033.GA4165@node.dhcp.inet.fi>
	<20150915121201.GA10104@redhat.com>
	<20150915134216.GA16093@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Sep 2015 16:42:16 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> I would rather like to see consolidated fault path between file and anon
> with ->vm_ops set for both. So vma_is_anonymous() will be trivial
> vma->vm_ops == anon_vm_ops.

People are noticing: https://bugzilla.kernel.org/show_bug.cgi?id=104691

How about I send Linus a revert of 6dc296e7df4c while we work out what
to do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
