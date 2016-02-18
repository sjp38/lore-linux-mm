Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 93B7A828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 06:06:15 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id a4so19629423wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:06:15 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id ws8si9545965wjc.16.2016.02.18.03.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 03:06:14 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id a4so19628685wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:06:14 -0800 (PST)
Date: Thu, 18 Feb 2016 13:06:12 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [LSF/MM TOPIC] THP, huge tmpfs, khugepaged
Message-ID: <20160218110612.GA27764@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

Hi,

I would like to attend LSF/MM 2016.

THP refcounting rework had been merged into v4.5 and I would like to
discuss next steps on THP front.

== huge tmpfs ==

One of the topic would be huge tmpfs. Currently we have two alternative
implementation of huge pages support in tmpfs:

  - Hugh has implemented it on top of new way to couple pages together --
    team pages. It's rather mature implementation which has been used in
    production.

  - I've implemented huge tmpfs on top of the same compound pages we use
    for THP. It's still under validation and hasn't got proper review.
    Few more iterations would be required to get it into shape.

Supporting two parallel implementation of the same feature is wasteful.
During the summit I would like to work out a consensus on what
implementation fits upstream more.

== khugepaged ==

Other topic I would like to talk about is khugepaged. New THP refcounting
opens some possibilities in this area.

We've got split_huge_pmd() decoupled from splitting underlying compound
page. We can separate collapse into two stages too: first collapse small
pages into a huge one, and then replace PTE tables with PMDs where it's
possible.

Even if the second stage has failed for some reason, we would still
benefit from fewer pages on LRU to deal with.

It also allows to collapse pages shared over fork(), which we cannot do at
the moment.

I personally would not have time to implement it any time soon, but I'll
help to anyone who wants to play with the idea.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
