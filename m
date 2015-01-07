Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C22E66B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 12:24:58 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id l18so1619259wgh.0
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 09:24:58 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id n13si5549751wjw.88.2015.01.07.09.24.57
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 09:24:58 -0800 (PST)
Date: Wed, 7 Jan 2015 19:24:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150107172452.GA7922@node.dhcp.inet.fi>
References: <cover.1420643264.git.petrcermak@chromium.org>
 <be6c14c9ac4551e94b814c5789242b4874a25dd3.1420643264.git.petrcermak@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be6c14c9ac4551e94b814c5789242b4874a25dd3.1420643264.git.petrcermak@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Cermak <petrcermak@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Hugh Dickins <hughd@google.com>

On Wed, Jan 07, 2015 at 05:06:54PM +0000, Petr Cermak wrote:
> Peak resident size of a process can be reset by writing "5" to
> /proc/pid/clear_refs. The driving use-case for this would be getting the
> peak RSS value, which can be retrieved from the VmHWM field in
> /proc/pid/status, per benchmark iteration or test scenario.

And how it's not an ABI break?

We have never-lowering VmHWM for 9+ years. How can you know that nobody
expects this behaviour?

And why do you reset hiwater_rss, but not hiwater_vm?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
