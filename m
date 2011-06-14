Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4A58B6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:07:00 -0400 (EDT)
Date: Tue, 14 Jun 2011 12:06:55 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] mm: thp: minor lock simplification in __khugepaged_exit
Message-ID: <20110614100655.GF6371@redhat.com>
References: <20110610233355.GO23047@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610233355.GO23047@sequoia.sous-sol.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 10, 2011 at 04:33:55PM -0700, Chris Wright wrote:
> The lock is released first thing in all three branches.  Simplify this
> by unconditionally releasing lock and remove else clause which was only
> there to be sure lock was released.
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
