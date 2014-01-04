Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 62E496B0031
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 02:31:52 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so1251297qaq.5
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 23:31:52 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id p3si61935178qah.18.2014.01.03.23.31.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 23:31:51 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so16533281pab.41
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 23:31:50 -0800 (PST)
Date: Sat, 4 Jan 2014 07:31:43 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCHv3 00/11] Intermix Lowmem and vmalloc
Message-ID: <20140104073143.GA5594@gmail.com>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
 <52C70024.1060605@sr71.net>
 <52C734F4.5020602@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52C734F4.5020602@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org

Hello,

On Fri, Jan 03, 2014 at 02:08:52PM -0800, Laura Abbott wrote:
> On 1/3/2014 10:23 AM, Dave Hansen wrote:
> >On 01/02/2014 01:53 PM, Laura Abbott wrote:
> >>The goal here is to allow as much lowmem to be mapped as if the block of memory
> >>was not reserved from the physical lowmem region. Previously, we had been
> >>hacking up the direct virt <-> phys translation to ignore a large region of
> >>memory. This did not scale for multiple holes of memory however.
> >
> >How much lowmem do these holes end up eating up in practice, ballpark?
> >I'm curious how painful this is going to get.
> >
> 
> In total, the worst case can be close to 100M with an average case
> around 70M-80M. The split and number of holes vary with the layout
> but end up with 60M-80M one hole and the rest in the other.

One more thing I'd like to know is how bad direct virt <->phys tranlsation
in scale POV and how often virt<->phys tranlsation is called in your worload
so what's the gain from this patch?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
