Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 451B16B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 02:31:34 -0500 (EST)
Date: Mon, 7 Nov 2011 02:31:27 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111107073127.GA7410@infradead.org>
References: <1320614101.3226.5.camel@offbook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320614101.3226.5.camel@offbook>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@gnu.org>
Cc: Hugh Dickins <hughd@google.com>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, Nov 06, 2011 at 06:15:01PM -0300, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <dave@gnu.org>
> 
> This patch adds a new RLIMIT_TMPFSQUOTA resource limit to restrict an individual user's quota across all mounted tmpfs filesystems.
> It's well known that a user can easily fill up commonly used directories (like /tmp, /dev/shm) causing programs to break through DoS.

Please jyst implement the normal user/group quota interfaces we use for other
filesystem.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
