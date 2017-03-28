Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A18536B03A1
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 11:39:38 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o70so54025474wrb.11
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 08:39:38 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id q52si5068763wrb.280.2017.03.28.08.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 08:39:37 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id x124so2102025wmf.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 08:39:37 -0700 (PDT)
Date: Tue, 28 Mar 2017 18:39:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: ksmd lockup - kernel 4.11-rc series
Message-ID: <20170328153934.ryjqmlgihkr4kjkc@node.shutemov.name>
References: <003401d2a750$19f98190$4dec84b0$@net>
 <000601d2a7d3$ed040f50$c70c2df0$@net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000601d2a7d3$ed040f50$c70c2df0$@net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Smythies <dsmythies@telus.net>
Cc: linux-mm@kvack.org, 'Hugh Dickins' <hughd@google.com>

On Tue, Mar 28, 2017 at 07:59:38AM -0700, Doug Smythies wrote:
> >> ./scripts/faddr2line <your vmlinux> page_vma_mapped_walk+0xe6
> >
> > I do not seem to be able to extract what you want:
> >
> With thanks to Tetsuo Handa (and this would be for 4.11-rc4):
> 
> $ ./scripts/faddr2line vmlinux page_vma_mapped_walk+0xe6
> page_vma_mapped_walk+0xe6/0x5b0:
> page_vma_mapped_walk at ??:?

Looks like you run it not on the vmlinux you've got the crash for.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
