Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 2112D6B0093
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:35:19 -0500 (EST)
Date: Mon, 17 Dec 2012 19:35:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] Revert "x86, mm: Make spurious_fault check
 explicitly check the PRESENT bit"
Message-ID: <20121217183502.GD32291@redhat.com>
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
 <1355767224-13298-2-git-send-email-aarcange@redhat.com>
 <50CF61AB.9010502@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50CF61AB.9010502@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Mon, Dec 17, 2012 at 10:17:15AM -0800, H. Peter Anvin wrote:
> On 12/17/2012 10:00 AM, Andrea Arcangeli wrote:
> > This reverts commit 660a293ea9be709b893d371fbc0328fcca33c33a.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Motivation/details?

It's all in 0/2 and 2/2. This one arrived first for whatever reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
