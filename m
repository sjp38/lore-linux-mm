Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 279C86B13F1
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 21:34:51 -0500 (EST)
Date: Tue, 7 Feb 2012 18:35:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix UP THP spin_is_locked BUGs
Message-Id: <20120207183531.58a3fe6f.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1202071616390.16273@eggly.anvils>
References: <alpine.LSU.2.00.1202071556460.7549@eggly.anvils>
	<20120207161209.52d065e1.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1202071616390.16273@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 7 Feb 2012 16:33:18 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> > Should we patch -stable too?
> 
> People seem to have survived very well without it so far, I think
> it's an unusual config combination, and quickly obvious if anyone
> hits it.  But I've no objection if you think it deserves -stable.

We may as well, I guess.  Runtime BUG() is rather unpleasant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
