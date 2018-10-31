Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41CB16B02E4
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:48:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id k25-v6so13249625pff.15
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:48:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s17-v6sor24047573plp.3.2018.10.31.02.48.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 02:48:48 -0700 (PDT)
Date: Wed, 31 Oct 2018 12:48:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm: introduce mm_[p4d|pud|pmd]_folded
Message-ID: <20181031094841.cawzzoddkemmufwl@kshutemo-mobl1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-2-git-send-email-schwidefsky@de.ibm.com>
 <20181031090255.bvmp3jnsdaunhzn7@kshutemo-mobl1>
 <20181031103536.0cab673d@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181031103536.0cab673d@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Oct 31, 2018 at 10:35:36AM +0100, Martin Schwidefsky wrote:
> > Maybe
> > 	return __is_defined(__PAGETABLE_P4D_FOLDED);
> > 
> > ?
>  
> I have tried that, doesn't work. The reason is that the
> __PAGETABLE_xxx_FOLDED defines to not have a value.
> 
> #define __PAGETABLE_P4D_FOLDED
> #define __PAGETABLE_PMD_FOLDED
> #define __PAGETABLE_PUD_FOLDED
> 
> While the definition of CONFIG_xxx symbols looks like this
> 
> #define CONFIG_xxx 1
> 
> The __is_defined needs the value for the __take_second_arg trick.

I guess this is easily fixable :)

-- 
 Kirill A. Shutemov
