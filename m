Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 04DFA900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 12:24:14 -0400 (EDT)
Received: by fxg9 with SMTP id 9so5342209fxg.14
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 09:24:12 -0700 (PDT)
Date: Sun, 31 Jul 2011 19:24:08 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH v2] mm/slab: use print_hex_dump
In-Reply-To: <alpine.DEB.2.00.1107291129470.16178@router.home>
Message-ID: <alpine.DEB.2.00.1107311923430.9837@tiger>
References: <1311941420-2463-1-git-send-email-bigeasy@linutronix.de> <alpine.DEB.2.00.1107291000360.15311@router.home> <20110729162213.GA28476@linutronix.de> <alpine.DEB.2.00.1107291129470.16178@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Fri, 29 Jul 2011, Sebastian Andrzej Siewior wrote:
>> less code and the advantage of ascii dump.

On Fri, 29 Jul 2011, Christoph Lameter wrote:
> Cool.
>
> Acked-by: Christoph Lameter <cl@linux.com>

I applied both patches and will queue them for linux-next once -rc1 is 
out. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
