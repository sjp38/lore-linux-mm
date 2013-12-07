Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f205.google.com (mail-ob0-f205.google.com [209.85.214.205])
	by kanga.kvack.org (Postfix) with ESMTP id BD79A6B0035
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 15:12:43 -0500 (EST)
Received: by mail-ob0-f205.google.com with SMTP id wo20so57834obc.8
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 12:12:43 -0800 (PST)
Received: from shutemov.name (shutemov.name. [204.155.152.216])
        by mx.google.com with ESMTP id b3si1619537qab.45.2013.12.07.01.16.47
        for <linux-mm@kvack.org>;
        Sat, 07 Dec 2013 01:16:47 -0800 (PST)
Date: Sat, 7 Dec 2013 10:21:17 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: oops in pgtable_trans_huge_withdraw
Message-ID: <20131207082117.GA17914@shutemov.name>
References: <20131206210254.GA7962@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131206210254.GA7962@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Fri, Dec 06, 2013 at 04:02:54PM -0500, Dave Jones wrote:
> I've spent a few days enhancing trinity's use of mmap's, trying to make it
> reproduce https://lkml.org/lkml/2013/12/4/499  
> Instead, I hit this.. related ?

Could you try this:

https://lkml.org/lkml/2013/12/4/499

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
