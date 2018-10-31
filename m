Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6304A6B000E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:23:50 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i81-v6so13622529pfj.1
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:23:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor24944137plb.17.2018.10.31.06.23.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 06:23:49 -0700 (PDT)
Date: Wed, 31 Oct 2018 16:23:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/4] mm: introduce mm_[p4d|pud|pmd]_folded
Message-ID: <20181031132343.h4r55euwrhkud6w2@kshutemo-mobl1>
References: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
 <1540990801-4261-3-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540990801-4261-3-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Oct 31, 2018 at 01:59:59PM +0100, Martin Schwidefsky wrote:
> Add three architecture overrideable functions to test if the
> p4d, pud, or pmd layer of a page table is folded or not.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
