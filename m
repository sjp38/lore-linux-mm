Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id CB8D26B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 16:02:38 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so2269763pdj.3
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 13:02:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id g5si15407990pav.201.2014.01.23.13.02.36
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 13:02:37 -0800 (PST)
Date: Thu, 23 Jan 2014 13:02:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
Message-Id: <20140123130235.61e2eca44d92b37936955ff1@linux-foundation.org>
In-Reply-To: <20140123151445.GX1574@moon>
References: <20140122190816.GB4963@suse.de>
	<20140122191928.GQ1574@moon>
	<20140122223325.GA30637@moon>
	<20140123095541.GD4963@suse.de>
	<20140123103606.GU1574@moon>
	<20140123121555.GV1574@moon>
	<20140123125543.GW1574@moon>
	<20140123151445.GX1574@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Mel Gorman <mgorman@suse.de>, gnome@rvzt.net, grawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, 23 Jan 2014 19:14:45 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> VM_SOFTDIRTY bit affects vma merge routine: if two VMAs has all
> bits in vm_flags matched except dirty bit the kernel can't longer
> merge them and this forces the kernel to generate new VMAs instead.

Do you intend to alter the brk() and binprm code to set VM_SOFTDIRTY?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
