Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1DE2A6B02BE
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 01:47:43 -0500 (EST)
Received: by lahi5 with SMTP id i5so232596lah.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 22:47:40 -0800 (PST)
Date: Wed, 14 Dec 2011 08:47:36 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1323845054.2846.18.camel@edumazet-laptop>
Message-ID: <alpine.LFD.2.02.1112140846290.1841@tux.localdomain>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>  <alpine.DEB.2.00.1112020842280.10975@router.home>  <1323419402.16790.6105.camel@debian>  <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
 <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>  <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>  <alpine.DEB.2.00.1112131835100.31514@chino.kir.corp.google.com>  <1323842761.16790.8295.camel@debian>
 <1323845054.2846.18.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Alex,Shi" <alex.shi@intel.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 14 Dec 2011, Eric Dumazet wrote:
> We should try to batch things a bit, instead of doing a very small unit
> of work in slow path.
>
> We now have a very fast fastpath, but inefficient slow path.
>
> SLAB has a litle cache per cpu, we could add one to SLUB for freed
> objects, not belonging to current slab. This could avoid all these
> activate/deactivate overhead.

Yeah, this is definitely worth looking at.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
