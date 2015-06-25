Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 958796B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:46:39 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so58767573pdj.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:46:39 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id m3si46443210pdr.71.2015.06.25.11.46.38
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 11:46:38 -0700 (PDT)
Message-ID: <558C4C8E.5010107@intel.com>
Date: Thu, 25 Jun 2015 11:46:38 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de> <20150608174551.GA27558@gmail.com> <20150609084739.GQ26425@suse.de> <20150609103231.GA11026@gmail.com> <20150609112055.GS26425@suse.de> <20150609124328.GA23066@gmail.com> <5577078B.2000503@intel.com> <20150621202231.GB6766@node.dhcp.inet.fi> <20150625114819.GA20478@gmail.com>
In-Reply-To: <20150625114819.GA20478@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>

On 06/25/2015 04:48 AM, Ingo Molnar wrote:
> I've updated the benchmarks with 4K flushes as well. Changes to the previous 
> measurement:

Did you push these out somewhere?  The tip tmp.fpu branch hasn't seen
any updates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
