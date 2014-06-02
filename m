Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8213C6B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:16:56 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id t60so5214915wes.41
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:16:55 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id r3si10739064wjw.87.2014.06.02.08.16.37
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:16:37 -0700 (PDT)
Date: Mon, 2 Jun 2014 18:16:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] improve __GFP_COLD/__GFP_ZERO interaction
Message-ID: <20140602151629.GA8160@node.dhcp.inet.fi>
References: <538CAA520200007800016E87@mail.emea.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <538CAA520200007800016E87@mail.emea.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: linux-mm@kvack.org, David Vrabel <david.vrabel@citrix.com>, mingo@elte.hu, tglx@linutronix.de, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, hpa@zytor.com

On Mon, Jun 02, 2014 at 03:46:10PM +0100, Jan Beulich wrote:
> For cold page allocations using the normal clear_highpage() mechanism
> may be inefficient on certain architectures, namely due to needlessly
> replacing a good part of the data cache contents. Introduce an arch-
> overridable clear_cold_highpage() (using streaming non-temporal stores
> on x86, where an override gets implemented right away) to make use of
> in this specific case.
> 
> Leverage the impovement in the Xen balloon driver, eliminating the
> explicit scrub_page() function.

Any benchmark data?

I've tried non-temporal stores to clear huge pages, but it didn't helped
much. I believe it can vary between micro-architectures, but we need
numbers. I've played with Westmere that time.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
