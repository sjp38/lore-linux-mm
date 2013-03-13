Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 84C1F6B0027
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 17:01:04 -0400 (EDT)
Date: Wed, 13 Mar 2013 14:01:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/2] mm: limit growth of 3% hardcoded other user
 reserve
Message-Id: <20130313140102.234330566fd08a0c8e4e2732@linux-foundation.org>
In-Reply-To: <20130307015553.GA5495@localhost.localdomain>
References: <20130306235201.GA1421@localhost.localdomain>
	<20130312160136.b0f09ca7b1b4f2efe01f6617@linux-foundation.org>
	<20130307015553.GA5495@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Wed, 6 Mar 2013 20:55:53 -0500 Andrew Shewmaker <agshew@gmail.com> wrote:

> Should I enforce a minimum for the admin reserve? 8MB/128MB for the 
> overcommit guess/never modes? I was hesitant to do that since my 
> numbers are based a full-featured distro's versions of login, bash,
> etc. A more svelte distro based on BusyBox might want different 
> minimums.

I'd say not.  It requires CAP_SYS_ADMIN and we generally prefer to give
root the flexibility to shoot his foot off if he feels so inclined.

> I have a question concerning the variable names. Might a person 
> looking at the source be confused why admin_reserve_kbytes and 
> user_reserve_kbytes are not included in totalreserve_pages? Should 
> I use a word other than "reserve" in the names, like "safetynet"? 
> I can't think of anything better. Maybe it isn't a concern, but 
> I didn't want to cause confusion.

mm..  I wouldn't worry about it personally.  As long as we have nice
comments at the various definition sites, readers should be able to
work out the difference quite easily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
