Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id AD7CD6B005A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:48:31 -0400 (EDT)
Date: Fri, 21 Sep 2012 14:48:22 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 3/9] Revert "mm: compaction: abort compaction loop if
 lock is contended or run too long"
Message-ID: <20120921174821.GC6665@optiplex.redhat.com>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348224383-1499-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 11:46:17AM +0100, Mel Gorman wrote:
> This reverts
> mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long.patch
> as it is replaced by a later patch in the series.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
