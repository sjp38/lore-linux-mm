Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9B5EF6B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 14:40:22 -0400 (EDT)
Received: by mail-vb0-f49.google.com with SMTP id fo1so1515034vbb.22
        for <linux-mm@kvack.org>; Wed, 16 May 2012 11:40:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205141352440.26304@router.home>
References: <1337020877-20087-1-git-send-email-pshelar@nicira.com>
	<alpine.DEB.2.00.1205141352440.26304@router.home>
Date: Wed, 16 May 2012 11:40:21 -0700
Message-ID: <CALnjE+r2OQ5YmpCjDS09uQ5B2jMEWCF3V7NbZ0Q6jGwVhoZS9Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Fix slab->page flags corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andrea@qumranet.com, aarcange@redhat.com
Cc: penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com, Christoph Lameter <cl@linux.com>

On Mon, May 14, 2012 at 11:53 AM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 14 May 2012, Pravin B Shelar wrote:
>
>> Transparent huge pages can change page->flags (PG_compound_lock)
>> without taking Slab lock. Since THP can not break slab pages we can
>> safely access compound page without taking compound lock.
>>
>> Specificly this patch fixes race between compound_unlock and slab
>> functions which does page-flags update. This can occur when
>> get_page/put_page is called on page from slab object.
>
> You need to also get this revbiewed by the THP folks like Andrea &
> friends.

Hi Andrea,

Can you comment on this patch.

Thanks.

>
> Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
