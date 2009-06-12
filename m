Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 02EB26B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 09:15:23 -0400 (EDT)
Date: Fri, 12 Jun 2009 21:15:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
	feature is disabled
Message-ID: <20090612131541.GA6751@localhost>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612100050.GC25568@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612100050.GC25568@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 06:00:50PM +0800, Andi Kleen wrote:
> On Thu, Jun 11, 2009 at 10:22:40PM +0800, Wu Fengguang wrote:
> > So as to eliminate one #ifdef in the c source.
> > 
> > Proposed by Nick Piggin.
> 
> Some older gccs didn't eliminate string constants for this,
> please check you don't get the string in the object file with 
> gcc 3.2 with the CONFIG disabled now.

Well I don't have gcc 3.2 at hand and it's missing from apt source.. 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
