Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 29CC86B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 14:07:21 -0400 (EDT)
Received: by mail-vw0-f41.google.com with SMTP id 4so2195535vws.14
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 11:07:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1106030904320.27151@router.home>
References: <1306999002-29738-1-git-send-email-ssouhlal@FreeBSD.org>
	<alpine.DEB.2.00.1106021011510.18350@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1106030904320.27151@router.home>
Date: Fri, 3 Jun 2011 21:07:18 +0300
Message-ID: <BANLkTimy2gLR-fuAgakwi91L=uuV9_4-rw@mail.gmail.com>
Subject: Re: [PATCH] SLAB: Record actual last user of freed objects.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Suleiman Souhlal <ssouhlal@freebsd.org>, suleiman@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com

On Fri, Jun 3, 2011 at 5:05 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 2 Jun 2011, David Rientjes wrote:
>
>> On Thu, 2 Jun 2011, Suleiman Souhlal wrote:
>>
>> > Currently, when using CONFIG_DEBUG_SLAB, we put in kfree() or
>> > kmem_cache_free() as the last user of free objects, which is not
>> > very useful, so change it to the caller of those functions instead.
>> >
>> > Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>>
>> Acked-by: David Rientjes <rientjes@google.com>
>
> Well note that this increases the overhead of a hot code path. But slub
> does the same
>
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
