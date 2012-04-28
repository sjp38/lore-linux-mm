Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B37526B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 09:15:20 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1226731yen.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 06:15:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1204271020530.29198@router.home>
References: <alpine.DEB.2.00.1204271020530.29198@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 28 Apr 2012 09:14:59 -0400
Message-ID: <CAHGf_=rcQXTpOW_-x8fi-RnS5MihkFY8D3pMLDffDYUWom8Q9Q@mail.gmail.com>
Subject: Re: slub memory hotplug: Allocate kmem_cache_node structure on new node
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Fri, Apr 27, 2012 at 11:29 AM, Christoph Lameter <cl@linux.com> wrote:
> Could you test this patch and see if it does the correct thing on a memory
> hotplug system?

Hmm..

Kamezawa-san, I can't access hotplug machine a while (maybe about 2 weeks).
Do you have any chance to do this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
