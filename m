Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9EA4F90013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:33:03 -0400 (EDT)
Date: Tue, 21 Jun 2011 15:32:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] mm: introduce no_ksm to disable totally KSM
Message-ID: <20110621133236.GP20843@redhat.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
 <1308643849-3325-4-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308643849-3325-4-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 04:10:45PM +0800, Amerigo Wang wrote:
> Introduce a new kernel parameter "no_ksm" to totally disable KSM.

Here as well this is the wrong approach. If you want to save memory,
you should make ksmd quit when run=0 and start only when setting
ksm/run=1. And move the daemon hashes and slabs initializations to the
ksmd daemon start. Not registering in sysfs and crippling down the
feature despite you loaded the proper .text into memory isn't good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
