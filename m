Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0996B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 21:01:55 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so8877403wmp.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 18:01:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c202si1301698wmh.93.2016.03.07.18.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 18:01:54 -0800 (PST)
Date: Mon, 7 Mar 2016 18:02:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm broken on arm with ebc495cfcea9 (mm: cleanup *pte_alloc*
 interfaces)
Message-Id: <20160307180205.1df26ec3.akpm@linux-foundation.org>
In-Reply-To: <56DE2A92.5010806@redhat.com>
References: <56DE2A92.5010806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 7 Mar 2016 17:27:46 -0800 Laura Abbott <labbott@redhat.com> wrote:

> Hi,
> 
> I just tried the master of mmotm and ran into compilation issues on arm:
> 
> ...
>
> It looks like this is caused by ebc495cfcea9 (mm: cleanup *pte_alloc* interfaces)
> which added
> 
> #define pte_alloc(mm, pmd, address)                     \
>          (unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, pmd, address))
> 
> 

http://ozlabs.org/~akpm/mmots/broken-out/mm-cleanup-pte_alloc-interfaces-fix.patch
and
http://ozlabs.org/~akpm/mmots/broken-out/mm-cleanup-pte_alloc-interfaces-fix-2.patch
should fix up arm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
