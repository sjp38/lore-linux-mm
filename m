Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m3TDRt3M032004
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 14:27:57 +0100
Received: from fg-out-1718.google.com (fgad23.prod.google.com [10.86.55.23])
	by zps37.corp.google.com with ESMTP id m3TDRsr8010756
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 06:27:55 -0700
Received: by fg-out-1718.google.com with SMTP id d23so6627404fga.31
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 06:27:53 -0700 (PDT)
Message-ID: <d43160c70804290627g77a74e48k5a383dd441177293@mail.gmail.com>
Date: Tue, 29 Apr 2008 09:27:53 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: [PATCH 1/2] MM: Make page tables relocatable -- conditional flush (rc9)
In-Reply-To: <Pine.LNX.4.64.0804161221060.14718@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080414163933.A9628DCA48@localhost>
	 <20080414155702.ca7eb622.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0804161221060.14718@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@skynet.ie, apm@shadoween.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 16, 2008 at 3:22 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  The patch is interesting because it would allow the moving of page table
>  pages into MOVABLE sections and reduce the size of the UNMOVABLE
>  allocations signficantly (Ross: We need some numbers here). This in turn

Is there a standard test used to evaluate kernel memory fragmentation?
 I'm sure I can rig up a test to create huge amounts of fragmentation
with about 1/2 the pages being page tables.  However, I doubt that it
would reflect any real loads.  Similarly, if I check the memory
fragmentation on my test system right after it's been booted, I won't
see much fragmentation and page tables won't be causing any trouble.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
