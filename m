Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1A1546B004A
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 14:01:26 -0400 (EDT)
Date: Tue, 12 Jul 2011 20:01:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: do_wp_page recheck PageKsm after obtaining the page_lock,
 pte_same not enough
Message-ID: <20110712180120.GU23227@redhat.com>
References: <20110712165003.GP23227@redhat.com>
 <CAPQyPG5asX4t_hhzmCeXLRnerXxuD2v8CRfQ2_RZqUcqdToskQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPQyPG5asX4t_hhzmCeXLRnerXxuD2v8CRfQ2_RZqUcqdToskQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Johannes Weiner <jweiner@redhat.com>

On Wed, Jul 13, 2011 at 01:48:10AM +0800, Nai Xia wrote:
> I think in this case we should copy the page instead of going to unlock.
> 
> And I think reuse_swap_page() has checked the PageKsm(page) inside and
> in this case it will go to the copy path already?

yes this is why it's unnecessary, I've been a bit in a paranoid mode
on this code lately, one more check wouldn't have hurted but it's
definitely unnecessary so please ignore...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
