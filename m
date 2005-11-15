From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 01/05] NUMA: Generic code
Date: Tue, 15 Nov 2005 15:15:04 +0100
References: <20051110090920.8083.54147.sendpatchset@cherry.local> <200511110516.37980.ak@suse.de> <aec7e5c30511150034t5ff9e362jb3261e2e23479b31@mail.gmail.com>
In-Reply-To: <aec7e5c30511150034t5ff9e362jb3261e2e23479b31@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511151515.05201.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Tuesday 15 November 2005 09:34, Magnus Damm wrote:

> 
> My plan with breaking out the NUMA emulation code was to merge my i386
> stuff with the x86_64 code, but as you say - it might be overkill.
> 
> What do you think about the fact that real NUMA nodes now can be
> divided into several smaller nodes?

Is it really needed? I never needed it.  Normally numa emulation 
is just for basic numa testing, and for that just an independent
split is good enough.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
