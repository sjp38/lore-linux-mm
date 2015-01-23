Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C57076B006C
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:06:35 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id v10so4736448pde.10
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:06:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id el12si9703847pdb.23.2015.01.22.16.06.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 16:06:34 -0800 (PST)
Date: Thu, 22 Jan 2015 16:06:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: add 'foreign' alias for the 'pinned' page flag
Message-Id: <20150122160633.350f22805e20c0c432755e02@linux-foundation.org>
In-Reply-To: <1421682443-20509-3-git-send-email-david.vrabel@citrix.com>
References: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
	<1421682443-20509-3-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jenny Herbert <jennifer.herbert@citrix.com>

On Mon, 19 Jan 2015 15:47:23 +0000 David Vrabel <david.vrabel@citrix.com> wrote:

> From: Jenny Herbert <jennifer.herbert@citrix.com>
> 
> The foreign page flag will be used by Xen guests to mark pages that
> have grant mappings of frames from other (foreign) guests.
> 
> The foreign flag is an alias for the existing (Xen-specific) pinned
> flag.  This is safe because pinned is only used on pages used for page
> tables and these cannot also be foreign.
> 

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
