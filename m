Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA2C6B0003
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 01:05:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z22so3205797pfi.7
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 22:05:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q127si2737139pfb.1.2018.04.27.22.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 22:05:08 -0700 (PDT)
Date: Sat, 28 Apr 2018 07:04:58 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180428050458.GF29422@kroah.com>
References: <20180428001526.22475-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180428001526.22475-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: arnd@arndb.de, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 27, 2018 at 05:15:26PM -0700, Luis R. Rodriguez wrote:
> Some architectures do not define PAGE_KERNEL_RO, best we can do
> for them is to provide a fallback onto PAGE_KERNEL. Remove the
> hack from the firmware loader and move it onto the asm-generic
> header, and document while at it the affected architectures
> which do not have a PAGE_KERNEL_RO:
> 
>   o alpha
>   o ia64
>   o m68k
>   o mips
>   o sparc64
>   o sparc
> 
> Blessed-by: 0-day

New tag?  :)
