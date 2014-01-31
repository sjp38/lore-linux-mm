Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id C022D6B0037
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 16:47:19 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so4884492pbc.22
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 13:47:19 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yg10si5611314pbc.332.2014.01.31.13.47.18
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 13:47:18 -0800 (PST)
Message-ID: <52EC19E6.9010509@intel.com>
Date: Fri, 31 Jan 2014 13:47:18 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Fixing large block devices on 32 bit
References: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: lsf-pc@lists.linux-foundation.org

On 01/31/2014 11:02 AM, James Bottomley wrote:
>      3. Increase pgoff_t and the radix tree indexes to u64 for
>         CONFIG_LBDAF.  This will blow out the size of struct page on 32
>         bits by 4 bytes and may have other knock on effects, but at
>         least it will be transparent.

I'm not sure how many acrobatics we want to go through for 32-bit, but...

Between page->mapping and page->index, we have 64 bits of space, which
*should* be plenty to uniquely identify a block.  We could easily add a
second-level lookup somewhere so that we store some cookie for the
address_space instead of a direct pointer.  How many devices would need,
practically?  8 bits worth?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
