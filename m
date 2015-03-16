Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 218D26B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 07:00:38 -0400 (EDT)
Received: by wibg7 with SMTP id g7so34222579wib.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:00:37 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id n2si17150330wif.35.2015.03.16.04.00.35
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 04:00:36 -0700 (PDT)
Date: Mon, 16 Mar 2015 13:00:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: trigger panic on bad page or PTE states if
 panic_on_oops
Message-ID: <20150316110033.GA20546@node.dhcp.inet.fi>
References: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 16, 2015 at 09:37:01AM +0100, Christian Borntraeger wrote:
> while debugging a memory management problem it helped a lot to
> get a system dump as early as possible for bad page states.
> 
> Lets assume that if panic_on_oops is set then the system should
> not continue with broken mm data structures.

bed_pte is not an oops.

Probably we should consider putting VM_BUG() at the end of these
functions instead.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
