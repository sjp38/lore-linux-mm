Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD0426B0256
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:27:17 -0500 (EST)
Received: by wmvv187 with SMTP id v187so223886453wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:27:17 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ki4si5520675wjc.178.2015.12.08.09.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 09:27:16 -0800 (PST)
Date: Tue, 8 Dec 2015 18:26:11 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 15/34] mm: factor out VMA fault permission checking
In-Reply-To: <20151204011445.19B1F2B3@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081825470.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011445.19B1F2B3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> This code matches a fault condition up with the VMA and ensures
> that the VMA allows the fault to be handled instead of just
> erroring out.
> 
> We will be extending this in a moment to comprehend protection
> keys.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
