Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A80006B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:49:59 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:59:28 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/5] HWPOISON: remove early kill option for now
Message-ID: <20090612095928.GB25568@one.firstfloor.org>
References: <20090611142239.192891591@intel.com> <20090611144430.682162784@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611144430.682162784@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 10:22:42PM +0800, Wu Fengguang wrote:
> It needs more thoughts, and is not a must have for .31.

Please don't do that. I don't think the problem Hugh described is fatal
and there are some scenarios where it is needed.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
