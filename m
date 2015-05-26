Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 18ADE6B0121
	for <linux-mm@kvack.org>; Tue, 26 May 2015 10:59:06 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so67552154wic.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:59:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si18578603wia.63.2015.05.26.07.59.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 07:59:04 -0700 (PDT)
Date: Tue, 26 May 2015 16:58:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150526145846.GK26958@redhat.com>
References: <20150524193404.GD16910@cbox>
 <20150525141525.GB26958@redhat.com>
 <20150526080848.GA27075@cbox>
 <CAPvkgC3kTgP720CawpfvLbm90FCs9UGNP3WOAamOD=UEgKoQCw@mail.gmail.com>
 <20150526143547.GA22363@cbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526143547.GA22363@cbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@linaro.org>
Cc: Steve Capper <steve.capper@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, ebru.akagunduz@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, May 26, 2015 at 04:35:47PM +0200, Christoffer Dall wrote:
> Any chance you could send me the memhog tool?

memhog is just the first that come to mind because I got it
preinstalled everywhere (I only miss it on cyanogenmod as there's no
numactl there... yet).

Anything else would do as well, as long as you allocate lots of
anonymous memory (malloc(); bzero() or just write 1 byte every
4k). The tmpfs trick was fine as well as you'd end up swapping the
anonymous memory allocated by the running apps.

This would be the python version which I actually used sometime if I
couldn't find something preinstalled and I didn't want to install
packages.

echo 1 >/proc/sys/vm/overcommit_memory
python
a = "a"
while True:
	a += a

This is the more polished way, I just happen to have it installed
everywhere (except the cellphone) so I tend to use it, I think it's
simpler to install the numactl package.

https://github.com/numactl/numactl/blob/master/memhog.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
