Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A3F246B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 18:39:58 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id z12so11838483wgg.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 15:39:58 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id wu10si50545918wjc.143.2015.01.14.15.39.57
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 15:39:58 -0800 (PST)
Date: Thu, 15 Jan 2015 01:39:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150114233954.GB14615@node.dhcp.inet.fi>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
 <20150114152225.GB31484@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114152225.GB31484@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Cermak <petrcermak@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Hugh Dickins <hughd@google.com>

On Wed, Jan 14, 2015 at 03:22:25PM +0000, Petr Cermak wrote:
> On Wed, Jan 07, 2015 at 07:24:52PM +0200, Kirill A. Shutemov wrote:
> > And how it's not an ABI break?
> I don't think this is an ABI break because the current behaviour is not
> changed unless you write "5" to /proc/pid/clear_refs. If you do, you are
> explicitly requesting the new functionality.
> 
> > We have never-lowering VmHWM for 9+ years. How can you know that nobody
> > expects this behaviour?
> This is why we sent an RFC [1] several weeks ago. We expect this to be
> used mainly by performance-related tools (e.g. profilers) and from the
> comments in the code [2] VmHWM seems to be a best-effort counter. If this
> is strictly a no-go, I can only think of the following two alternatives:
> 
>   1. Add an extra resettable field to /proc/pid/status (e.g.
>      resettable_hiwater_rss). While this doesn't violate the current
>      definition of VmHWM, it adds an extra line to /proc/pid/status,
>      which I think is a much bigger issue.
>   2. Introduce a new proc fs file to task_mmu (e.g.
>      /proc/pid/profiler_stats), but this feels like overengineering.

BTW, we have memory.max_usage_in_byte in memory cgroup. And it's resetable.
Wouldn't it be enough for your profiling use-case?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
