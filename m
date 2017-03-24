Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3116B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 08:07:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n55so387413wrn.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:07:09 -0700 (PDT)
Received: from mail-wr0-x22e.google.com (mail-wr0-x22e.google.com. [2a00:1450:400c:c0c::22e])
        by mx.google.com with ESMTPS id t6si2668771wmg.91.2017.03.24.05.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 05:06:27 -0700 (PDT)
Received: by mail-wr0-x22e.google.com with SMTP id u108so258951wrb.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:06:27 -0700 (PDT)
Date: Fri, 24 Mar 2017 15:06:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: linux-next: something wrong with 5-level paging
Message-ID: <20170324120625.osoqp63x3sukijgj@node.shutemov.name>
References: <CANaxB-wtxWcHyOV1gJRjWvAi88FitcTYQzDUAvwV23YyQX0X+w@mail.gmail.com>
 <CANaxB-ygnT+HGy1FsEYb626209jvVzm3hr_ZXE=rOPomSbTm-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANaxB-ygnT+HGy1FsEYb626209jvVzm3hr_ZXE=rOPomSbTm-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrei Vagin <avagin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Mar 21, 2017 at 03:03:20PM -0700, Andrei Vagin wrote:
> Hi,
> 
> I reproduced it locally. This kernel doesn't boot via kexec, but it
> can boot if we set it via the qemu -kernel option. Then I tried to
> boot the same kernel again via kexec and got a bug in dmesg:
> [ 1252.014292] BUG: unable to handle kernel paging request at ffffd204f000f000
> [ 1252.015093] IP: ident_pmd_init.isra.5+0x5a/0xb0
> [ 1252.015636] PGD 0

Sorry for this.

http://lkml.kernel.org/r/20170324120458.nw3fwpmdptjtj5qb@node.shutemov.name

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
