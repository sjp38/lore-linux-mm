Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 69C646B0038
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:14:28 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so1041307pdi.30
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:14:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id je4si919595pbd.147.2014.08.29.12.14.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 12:14:27 -0700 (PDT)
Date: Fri, 29 Aug 2014 12:14:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] Tidy up of modules using seq_open()
Message-Id: <20140829121426.4044f2a330f9d74fe37f7825@linux-foundation.org>
In-Reply-To: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Jones <rob.jones@codethink.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-kernel@codethink.co.uk

On Fri, 29 Aug 2014 17:06:36 +0100 Rob Jones <rob.jones@codethink.co.uk> wrote:

> Many modules use seq_open() when seq_open_private() or
> __seq_open_private() would be more appropriate and result in
> simpler, cleaner code.
> 
> This patch sequence changes those instances in IPC, MM and LIB.

Looks good to me.

I can't begin to imagine why we added the global, exported-to-modules
seq_open_private() without bothering to document it, so any time you
feel like adding the missing kerneldoc...

And psize should have been size_t, ho hum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
