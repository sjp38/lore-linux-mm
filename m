Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C76B6B00F2
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 18:46:43 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p6JMkeiu021295
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:46:40 -0700
Received: from iwi5 (iwi5.prod.google.com [10.241.67.5])
	by hpaq14.eem.corp.google.com with ESMTP id p6JMkck0027387
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:46:39 -0700
Received: by iwi5 with SMTP id 5so6335641iwi.35
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:46:37 -0700 (PDT)
Date: Tue, 19 Jul 2011 15:46:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/12] mm: let swap use exceptional entries
In-Reply-To: <20110713161121.17fd98a4.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1107191538460.1565@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <alpine.LSU.2.00.1106140342330.29206@sister.anvils> <20110618145254.1b333344.akpm@linux-foundation.org> <alpine.LSU.2.00.1107121501100.2112@sister.anvils>
 <20110713161121.17fd98a4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 13 Jul 2011, Andrew Morton wrote:
> On Tue, 12 Jul 2011 15:08:58 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > I'll keep the bland naming, if that's okay, but send a patch adding
> > a line of comment in such places.  Mentioning shmem, tmpfs, swap.
> 
> A better fix would be to create a nicely-documented filemap-specific
> function with a non-bland name which simply wraps
> radix_tree_exception().

I did yesterday try out page_tree_entry_is_not_a_page() to wrap
radix_tree_exceptional_entry(); but (a) I'm wary of negative names,
(b) it was hard to explain why radix_tree_deref_retry() is not a
part of that case, and (c) does a further wrapper help or obscure?

I've skirted the issue in the patch 3/3 I'm about to send you,
maybe you'll think it an improvement, maybe not: I'm neutral.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
