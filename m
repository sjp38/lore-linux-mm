Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4428B6B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 19:36:18 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 124so20343899pfg.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 16:36:18 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id z63si38660840pfi.63.2016.02.28.16.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 16:36:17 -0800 (PST)
Received: by mail-pa0-x236.google.com with SMTP id fy10so81689473pac.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 16:36:17 -0800 (PST)
Date: Sun, 28 Feb 2016 16:36:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [LSF/MM TOPIC] THP, huge tmpfs, khugepaged
In-Reply-To: <20160218110612.GA27764@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1602281618510.2997@eggly.anvils>
References: <20160218110612.GA27764@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 18 Feb 2016, Kirill A. Shutemov wrote:
> Hi,
> 
> I would like to attend LSF/MM 2016.
> 
> THP refcounting rework had been merged into v4.5 and I would like to
> discuss next steps on THP front.
> 
> == huge tmpfs ==
> 
> One of the topic would be huge tmpfs. Currently we have two alternative
> implementation of huge pages support in tmpfs:
> 
>   - Hugh has implemented it on top of new way to couple pages together --
>     team pages. It's rather mature implementation which has been used in
>     production.
> 
>   - I've implemented huge tmpfs on top of the same compound pages we use
>     for THP. It's still under validation and hasn't got proper review.
>     Few more iterations would be required to get it into shape.
> 
> Supporting two parallel implementation of the same feature is wasteful.
> During the summit I would like to work out a consensus on what
> implementation fits upstream more.

I would of course like to participate in this discussion too,
if it works out to be a separate session from the Huge Page Futures
session already proposed by Mike Kravetz.

Though to judge from last year's experience, when I think neither
Kirill nor I managed to engage the "audience" very much, I suspect
we'll get more from our own face-to-face discussion and over email.

But I can very well understand that Kirill would like to give me
some kind of kick start, given that my contribution to that email
has been nil so far over the last year.

Hugh

> 
> == khugepaged ==
> 
> Other topic I would like to talk about is khugepaged. New THP refcounting
> opens some possibilities in this area.
> 
> We've got split_huge_pmd() decoupled from splitting underlying compound
> page. We can separate collapse into two stages too: first collapse small
> pages into a huge one, and then replace PTE tables with PMDs where it's
> possible.
> 
> Even if the second stage has failed for some reason, we would still
> benefit from fewer pages on LRU to deal with.
> 
> It also allows to collapse pages shared over fork(), which we cannot do at
> the moment.
> 
> I personally would not have time to implement it any time soon, but I'll
> help to anyone who wants to play with the idea.
> 
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
