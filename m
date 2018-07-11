Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 326326B0010
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:40:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so17172305pfi.19
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:40:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w123-v6si20766471pfb.362.2018.07.11.15.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 15:40:29 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:40:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2/2] mm: Drop unneeded ->vm_ops checks
Message-Id: <20180711154027.66dd158b11ab144f2f776221@linux-foundation.org>
In-Reply-To: <20180711221742.GA9360@roeck-us.net>
References: <20180710134821.84709-3-kirill.shutemov@linux.intel.com>
	<20180711221742.GA9360@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 11 Jul 2018 15:17:42 -0700 Guenter Roeck <linux@roeck-us.net> wrote:

> On Tue, Jul 10, 2018 at 04:48:21PM +0300, Kirill A. Shutemov wrote:
> > We now have all VMAs with ->vm_ops set and don't need to check it for
> > NULL everywhere.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> This patch causes two of my qemu tests to fail:
> 	arm:mps2-an385:mps2_defconfig:mps2-an385
> 	xtensa:de212:kc705-nommu:nommu_kc705_defconfig
> 
> Both are nommu configurations.
> 
> Reverting the patch fixes the problem. Bisect log is attached for reference.

Thanks.  And there's the /dev/ion sysbot bug report.

mm-drop-unneeded-vm_ops-checks.patch needs some more work - let's drop it
for now.
