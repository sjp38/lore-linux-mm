Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3D766B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:23:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 3-v6so5042590plc.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:23:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16-v6sor24737826plo.4.2018.10.31.06.23.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 06:23:37 -0700 (PDT)
Date: Wed, 31 Oct 2018 16:23:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/4] mm: make the __PAGETABLE_PxD_FOLDED defines non-empty
Message-ID: <20181031132331.s5l77nsjoyiwhqhd@kshutemo-mobl1>
References: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
 <1540990801-4261-2-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540990801-4261-2-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Oct 31, 2018 at 01:59:58PM +0100, Martin Schwidefsky wrote:
> Change the currently empty defines for __PAGETABLE_PMD_FOLDED,
> __PAGETABLE_PUD_FOLDED and __PAGETABLE_P4D_FOLDED to return 1.
> This makes it possible to use __is_defined() to test if the
> preprocessor define exists.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
