Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD8F6B0035
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 13:16:12 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so13742750lab.29
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 10:16:11 -0700 (PDT)
Received: from cvs.linux-mips.org (eddie.linux-mips.org. [148.251.95.138])
        by mx.google.com with ESMTP id kz8si551140lab.23.2014.08.25.10.16.09
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 10:16:10 -0700 (PDT)
Received: from localhost.localdomain ([127.0.0.1]:54250 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27006728AbaHYRQJPYfQY (ORCPT <rfc822;linux-mm@kvack.org>);
        Mon, 25 Aug 2014 19:16:09 +0200
Date: Mon, 25 Aug 2014 19:16:00 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH v4 0/2] mm/highmem: make kmap cache coloring aware
Message-ID: <20140825171600.GH25892@linux-mips.org>
References: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>

On Sat, Aug 02, 2014 at 05:11:37AM +0400, Max Filippov wrote:

> this series adds mapping color control to the generic kmap code, allowing
> architectures with aliasing VIPT cache to use high memory. There's also
> use example of this new interface by xtensa.

I haven't actually ported this to MIPS but it certainly appears to be
the right framework to get highmem aliases handled on MIPS, too.

Though I still consider increasing PAGE_SIZE to 16k the preferable
solution because it will entirly do away with cache aliases.

Thanks,

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
