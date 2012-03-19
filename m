Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 0CF046B004D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 10:35:09 -0400 (EDT)
Message-ID: <4F6743C2.3090906@parallels.com>
Date: Mon, 19 Mar 2012 18:33:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: object allocation benchmark
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I was wondering: Which benchmark would be considered the canonical one 
to demonstrate the speed of the slub/slab after changes? In particular, 
I have the kmem-memcg in mind

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
