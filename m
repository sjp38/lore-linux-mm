Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 317616B0006
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:37:50 -0500 (EST)
Date: Thu, 21 Feb 2013 09:33:56 +0100 (CET)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <alpine.LFD.2.00.1302080948110.3225@localhost>
Message-ID: <alpine.LFD.2.00.1302210929590.19354@localhost>
References: <1360055531-26309-1-git-send-email-lczerner@redhat.com> <1360055531-26309-11-git-send-email-lczerner@redhat.com> <20130207154042.92430aed.akpm@linux-foundation.org> <alpine.LFD.2.00.1302080948110.3225@localhost>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1680678039-1361435868=:19354"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1680678039-1361435868=:19354
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Fri, 8 Feb 2013, Luka? Czerner wrote:

> Date: Fri, 8 Feb 2013 10:08:05 +0100 (CET)
> From: Luka? Czerner <lczerner@redhat.com>
> To: Andrew Morton <akpm@linux-foundation.org>
> Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org,
>     linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
>     linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>
> Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to handle
>      non page aligned ranges

..snip..

> > > +	/*
> > > +	 * 'start' and 'end' always covers the range of pages to be fully
> > > +	 * truncated. Partial pages are covered with 'partial_start' at the
> > > +	 * start of the range and 'partial_end' at the end of the range.
> > > +	 * Note that 'end' is exclusive while 'lend' is inclusive.
> > > +	 */
> > 
> > That helped ;)  So the bytes to be truncated are
> > 
> > (start*PAGE_SIZE + partial_start) -> (end*PAGE_SIZE + partial_end) - 1
> > 
> > yes?
> 
> The start of the range is not right, because 'start' and 'end'
> covers pages to be _fully_ truncated. See the while cycle and 
> then 'if (partial_start)' condition where we search for the
> page (start - 1) and do_invalidate within that page.
> 
> So it should be like this:
> 
> 
> (start*PAGE_SIZE - partial_start*(PAGE_SIZE - partial_start) ->
> (end*PAGE_END + partial_end) - 1
> 
> 
> assuming that you want the range to be inclusive on both sides.
> 
> -Lukas
> 

Hi Andrew,

what's the status of the patch set ? Do you have any more comments
or questions ? Can we get this in in this merge window ?

Thanks!
-Lukas
--8323328-1680678039-1361435868=:19354--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
