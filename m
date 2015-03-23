Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 246976B006E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:50:15 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so61465435wib.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:50:14 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id v10si1257859wju.8.2015.03.23.05.50.13
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 05:50:13 -0700 (PDT)
Date: Mon, 23 Mar 2015 14:50:09 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 11/24] huge tmpfs: shrinker to migrate and free underused
 holes
Message-ID: <20150323125009.GC30088@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
 <alpine.LSU.2.11.1502202008010.14414@eggly.anvils>
 <550AFFD5.40607@yandex-team.ru>
 <alpine.LSU.2.11.1503222046510.5278@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503222046510.5278@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 22, 2015 at 09:40:02PM -0700, Hugh Dickins wrote:
> (I think Kirill has a problem of that kind in his page_remove_rmap scan).

Ouch! Thanks for noticing this. 

It should work fine while we are anon-THP only, but it need to be fixed to
work with files.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
