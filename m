Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B81138D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 00:33:01 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p1R5Wv60024238
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 21:32:57 -0800
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe13.cbf.corp.google.com with ESMTP id p1R5WtHg004201
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 21:32:56 -0800
Received: by pzk30 with SMTP id 30so473598pzk.3
        for <linux-mm@kvack.org>; Sat, 26 Feb 2011 21:32:55 -0800 (PST)
Date: Sat, 26 Feb 2011 21:32:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: fix ksize() build error
In-Reply-To: <1298747426-8236-1-git-send-email-mk@lab.zgora.pl>
Message-ID: <alpine.DEB.2.00.1102262132320.12215@chino.kir.corp.google.com>
References: <20110225105205.5a1309bb.randy.dunlap@oracle.com> <1298747426-8236-1-git-send-email-mk@lab.zgora.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mariusz Kozlowski <mk@lab.zgora.pl>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Eric Dumazet <eric.dumazet@gmail.com>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 26 Feb 2011, Mariusz Kozlowski wrote:

> mm/slub.c: In function 'ksize':
> mm/slub.c:2728: error: implicit declaration of function 'slab_ksize'
> 
> slab_ksize() needs to go out of CONFIG_SLUB_DEBUG section.
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
