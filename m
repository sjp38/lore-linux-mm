Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 583116B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:42:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44so14632371wry.5
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:42:10 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id r6si1227527wmr.155.2017.05.22.23.42.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 23:42:09 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id k15so35861866wmh.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:42:08 -0700 (PDT)
Date: Tue, 23 May 2017 08:42:06 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 5/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE
Message-ID: <20170523064206.g4275jdoj3mtbf4o@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com>
 <20170523040524.13717-5-oohall@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523040524.13717-5-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org


* Oliver O'Halloran <oohall@gmail.com> wrote:

> Currently ZONE_DEVICE depends on X86_64. This is fine for now, but it
> will get unwieldly as new platforms get ZONE_DEVICE support. Moving it
> to an arch selected Kconfig option to save us some trouble in the
> future.
> 
> Cc: x86@kernel.org
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
