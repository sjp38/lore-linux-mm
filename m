Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8A0B06B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 15:03:16 -0400 (EDT)
Date: Wed, 22 Aug 2012 12:03:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mempolicy: Remove mempolicy sharing
Message-Id: <20120822120314.9fc30d47.akpm@linux-foundation.org>
In-Reply-To: <1345480594-27032-3-git-send-email-mgorman@suse.de>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
	<1345480594-27032-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 20 Aug 2012 17:36:31 +0100
Mel Gorman <mgorman@suse.de> wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Dave Jones' system call fuzz testing tool "trinity" triggered the following
> bug error with slab debugging enabled
> 
> ...
>
> Cc: <stable@vger.kernel.org>

The patch dosn't apply to 3.5 at all well.  I don't see much point in
retaining the stable tag so I think I'll remove it, and suggest that
you prepare a fresh patch for Greg and explain the situation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
