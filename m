Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4624B6B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:05:46 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so176398712wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:05:45 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id hf9si4558927wjc.36.2015.09.22.13.05.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 13:05:45 -0700 (PDT)
Date: Tue, 22 Sep 2015 22:05:06 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 11/26] x86, pkeys: add functions for set/fetch PKRU
In-Reply-To: <20150916174906.4F375766@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1509222204020.5606@nanos>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174906.4F375766@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 16 Sep 2015, Dave Hansen wrote:

> 
> This adds the raw instructions to access PKRU as well as some
> accessor functions that correctly handle when the CPU does
> not support the instruction.  We don't use them here, but
> we will use read_pkru() in the next patch.
> 
> I do not see an immediate use for write_pkru().  But, we put it
> here for partity with its twin.

So that read_pkru() doesn't feel so lonely? I can't follow that logic.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
