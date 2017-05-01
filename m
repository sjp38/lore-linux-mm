Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 272FA6B02FA
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:34:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b28so11875425wrb.2
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:34:10 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id u189si9651722wmg.140.2017.05.01.11.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:34:08 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id w50so14499488wrc.0
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:34:08 -0700 (PDT)
Subject: Re: [PATCH man-pages 0/5] {ioctl_}userfaultfd.2: yet another update
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <352eee49-d6d1-3e82-a558-2341484c81f3@gmail.com>
Date: Mon, 1 May 2017 20:34:07 +0200
MIME-Version: 1.0
In-Reply-To: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hi Mike,

On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> Hi Michael,
> 
> These updates pretty much complete the coverage of 4.11 additions, IMHO.

Thanks for this, but we still await input from Andrea
on various points.

> Mike Rapoport (5):
>   ioctl_userfaultfd.2: update description of shared memory areas
>   ioctl_userfaultfd.2: UFFDIO_COPY: add ENOENT and ENOSPC description
>   ioctl_userfaultfd.2: add BUGS section
>   userfaultfd.2: add note about asynchronios events delivery
>   userfaultfd.2: update VERSIONS section with 4.11 chanegs
> 
>  man2/ioctl_userfaultfd.2 | 35 +++++++++++++++++++++++++++++++++--
>  man2/userfaultfd.2       | 15 +++++++++++++++
>  2 files changed, 48 insertions(+), 2 deletions(-)

I've applied all of the above, and done some light editing.

Could you please check my changes in the following commits:

5191c68806c8ac73fdc89586cde434d2766abb5c
265225c1e2311ae26ead116e6c8d2cedd46144fa

Thanks,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
