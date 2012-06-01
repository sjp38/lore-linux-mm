Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9E8266B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:18:24 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so3612594obb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:18:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1206010934460.2163@tux.localdomain>
References: <1336665378-2967-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1205142332060.19403@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1205311351540.2764@chino.kir.corp.google.com>
	<alpine.LFD.2.02.1206010934460.2163@tux.localdomain>
Date: Fri, 1 Jun 2012 21:18:23 +0900
Message-ID: <CAAmzW4PYMExvnCPjLphEOCiqjGMy6TxVQCtvQdW8tew4kNQ0uw@mail.gmail.com>
Subject: Re: [PATCH] slub: change cmpxchg_double_slab in get_freelist() to __cmpxchg_double_slab
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

> We now made get_freelist() *require* interrupts to be disabled which
> deserves a comment, no?

I resend patch(18 May) related to this comment.
See below link.
http://thread.gmane.org/gmane.linux.kernel.mm/78630/focus=78701

> Also, what do we gain from patches like this? It's somewhat
> counterintuitive that we have a function with "cmpxchg" in it which is not
> always atomic (i.e. you need to have interrupts disabled).

Hmm...
This patch have a minor impact which saves a few instructions.
But we already have a "__cmpxchg" version which works in irq disabled,
so there is no reason for not applying it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
