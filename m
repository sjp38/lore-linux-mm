Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4C16B0023
	for <linux-mm@kvack.org>; Thu,  5 May 2011 21:12:21 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p461CJFu009270
	for <linux-mm@kvack.org>; Thu, 5 May 2011 18:12:19 -0700
Received: from gxk7 (gxk7.prod.google.com [10.202.11.7])
	by kpbe13.cbf.corp.google.com with ESMTP id p461Bf0V030521
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 5 May 2011 18:12:18 -0700
Received: by gxk7 with SMTP id 7so1321255gxk.21
        for <linux-mm@kvack.org>; Thu, 05 May 2011 18:12:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110505063012.GA11529@tiehlicka.suse.cz>
References: <20110503141044.GA25351@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1105031142260.7349@sister.anvils>
	<20110504083005.GA1375@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1105041016110.23159@sister.anvils>
	<20110505063012.GA11529@tiehlicka.suse.cz>
Date: Thu, 5 May 2011 18:12:12 -0700
Message-ID: <BANLkTikGduoi8DVapz0H-uVPrrXPYF=YGg@mail.gmail.com>
Subject: Re: [PATCH resend] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, May 4, 2011 at 11:30 PM, Michal Hocko <mhocko@suse.cz> wrote:

> So I think the flag should be used that way. If we ever going to add a
> new architecture like IA64 which uses both ways of expanding we should
> make it easier by minimizing the places which have to be examined.

If, yes.  Let's just agree to disagree.  It looks like I'm preferring
to think of the ia64 case as exceptional, and I want to be reminded of
that peculiar case; whereas you are wanting to generalize and make it
not stand out.  Both valid.

> OK, now, with the cleanup patch, we have expand_stack and
> expand_stack_{downwards,upwards}. I will repost the patch to Andrew with
> up and down cases renamed. Does it work for you?

Sounds right.

>
>> But it's always going to be somewhat confusing and asymmetrical
>> because of the ia64 register backing store case.
>
> How come? We would have expand_stack which is pretty much clear that it
> is expanding stack in the architecture specific way. And then we would
> have expand_{upwards,downward} which are clear about way how we expand
> whatever VMA, right?

Right.  I'm preferring to be reminded of the confusion and asymmetry,
you're preferring to smooth over it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
