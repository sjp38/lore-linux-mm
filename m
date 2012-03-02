Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A82B46B0092
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 17:58:13 -0500 (EST)
Date: Fri, 2 Mar 2012 14:58:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
Message-Id: <20120302145811.93bb49e9.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1203021444040.3448@eggly.anvils>
References: <20120215183317.GA26977@redhat.com>
	<alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
	<20120216070753.GA23585@redhat.com>
	<alpine.LSU.2.00.1202160130500.16147@eggly.anvils>
	<20120216214245.GD23585@redhat.com>
	<alpine.LSU.2.00.1203021444040.3448@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Jones <davej@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

On Fri, 2 Mar 2012 14:53:32 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Subject: Re: exit_mmap() BUG_ON triggering since 3.1
> ...
> Subject: [PATCH] mm: thp: fix BUG on mm->nr_ptes

So it's needed in 3.1.x and 3.2.x?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
