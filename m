Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3C06B025E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:42:02 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id a29so182818593qtb.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:42:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h56si15678479qte.96.2017.01.25.06.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 06:42:01 -0800 (PST)
Date: Wed, 25 Jan 2017 06:41:49 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4] mm: add arch-independent testcases for RODATA
Message-ID: <20170125144149.GA970@bombadil.infradead.org>
References: <20170125141833.GA27658@pjb1027-Latitude-E5410>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125141833.GA27658@pjb1027-Latitude-E5410>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jinbum Park <jinb.park7@gmail.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, keescook@chromium.org, arjan@linux.intel.com, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@redhat.com, kernel-hardening@lists.openwall.com, mark.rutland@arm.com, kernel-janitors@vger.kernel.org, linux@armlinux.org.uk

On Wed, Jan 25, 2017 at 11:18:33PM +0900, Jinbum Park wrote:
> +	/* test 2: write to the variable; this should fault */
> +	/*
> +	 * This must be written in assembly to be able to catch the
> +	 * exception that is supposed to happen in the correct case.
> +	 *
> +	 * So that probe_kernel_write is used to write
> +	 * arch-independent assembly.
> +	 */

This comment makes no sense.  Better to just delete the comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
