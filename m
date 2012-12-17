Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B5D766B0089
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:17:17 -0500 (EST)
Message-ID: <50CF61AB.9010502@linux.intel.com>
Date: Mon, 17 Dec 2012 10:17:15 -0800
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Revert "x86, mm: Make spurious_fault check explicitly
 check the PRESENT bit"
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com> <1355767224-13298-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1355767224-13298-2-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 12/17/2012 10:00 AM, Andrea Arcangeli wrote:
> This reverts commit 660a293ea9be709b893d371fbc0328fcca33c33a.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Motivation/details?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
