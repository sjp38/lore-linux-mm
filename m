Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3D1186B0068
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 13:28:46 -0400 (EDT)
From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: shrink_slab(), shrinkers and aggresivity
Date: Tue, 10 Sep 2013 19:28:44 +0200
Message-ID: <87li3437sj.fsf@free.fr>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I was wondering if there was such a notion as "shrinkers aggresivity".
Or, in other words, I wondered why shrink_slab(), in its parameters, doesn't
have the priority, ie. the (struct scan_control)->priority.

The usecase I have in mind would be a shrinker which behaves differently,
depending on this priority :
 - if priority is low, only drop a subset of its objects, the "cold objects"
 - if priority is high, drop each and every possible object

In a GPU cache for example, they are objects that are not used anymore in the
GPU, but some are still mapped into the GPU's MMU table. The GPU MMU
manipulation being costly, such a shrinker would :
 - on low priority, consider only the GPU MMU unmapped objects
 - on high prioriy, consider all GPU objects

Is it in the shrinker definition that no priority should ever be considered, is
it silly to consider having priority in (struct shrink_control) ?

Thanks in advance for your explanation.

-- 
Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
