Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 69C8F8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 13:29:22 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p18ITIlN025607
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:29:19 -0800
Received: from vxb37 (vxb37.prod.google.com [10.241.33.101])
	by kpbe18.cbf.corp.google.com with ESMTP id p18IPP47031549
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:29:17 -0800
Received: by vxb37 with SMTP id 37so2745001vxb.7
        for <linux-mm@kvack.org>; Tue, 08 Feb 2011 10:29:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297126056-14322-3-git-send-email-walken@google.com>
References: <1297126056-14322-1-git-send-email-walken@google.com>
	<1297126056-14322-3-git-send-email-walken@google.com>
Date: Tue, 8 Feb 2011 10:29:16 -0800
Message-ID: <AANLkTimXQJxFHC_NcBJkutiv9N_57DDHBUGawdKrt2xH@mail.gmail.com>
Subject: Re: [PATCH 2/2] mlock: do not munlock pages in __do_fault()
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Mon, Feb 7, 2011 at 4:47 PM, Michel Lespinasse <walken@google.com> wrote:
> If the page is going to be written to, __do_page needs to break COW.
> However, the old page (before breaking COW) was never mapped mapped into
> the current pte (__do_fault is only called when the pte is not present),
> so vmscan can't have marked the old page as PageMlocked due to being
> mapped in __do_fault's VMA. Therefore, __do_fault() does not need to worry
> about clearing PageMlocked() on the old page.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
