Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB346B0274
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 09:50:39 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so107414319igb.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 06:50:39 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id s8si9546554igd.59.2015.07.21.06.50.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 06:50:38 -0700 (PDT)
Date: Tue, 21 Jul 2015 08:50:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
In-Reply-To: <20150720232817.05f08663@redhat.com>
Message-ID: <alpine.DEB.2.11.1507210846060.27213@east.gentwo.org>
References: <20150715155934.17525.2835.stgit@devil> <20150715160212.17525.88123.stgit@devil> <20150716115756.311496af@redhat.com> <20150720025415.GA21760@js1304-P5Q-DELUXE> <20150720232817.05f08663@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>

On Mon, 20 Jul 2015, Jesper Dangaard Brouer wrote:

> Yes, I think it is merged... how do I turn off merging?

linux/Documentation/kernel-parameters.txt

        slab_nomerge    [MM]
                        Disable merging of slabs with similar size. May be
                        necessary if there is some reason to distinguish
                        allocs to different slabs. Debug options disable
                        merging on their own.
                        For more information see Documentation/vm/slub.txt.

        slab_max_order= [MM, SLAB]
                        Determines the maximum allowed order for slabs.
                        A high setting may cause OOMs due to memory
                        fragmentation.  Defaults to 1 for systems with
                        more than 32MB of RAM, 0 otherwise.


       slub_debug[=options[,slabs]]    [MM, SLUB]
                        Enabling slub_debug allows one to determine the
                        culprit if slab objects become corrupted. Enabling
                        slub_debug can create guard zones around objects and
                        may poison objects when not in use. Also tracks the
                        last alloc / free. For more information see
                        Documentation/vm/slub.txt.

        slub_max_order= [MM, SLUB]
                        Determines the maximum allowed order for slabs.
                        A high setting may cause OOMs due to memory
                        fragmentation. For more information see
                        Documentation/vm/slub.txt.

        slub_min_objects=       [MM, SLUB]
                        The minimum number of objects per slab. SLUB will
                        increase the slab order up to slub_max_order to
                        generate a sufficiently large slab able to contain
                        the number of objects indicated. The higher the number
                        of objects the smaller the overhead of tracking slabs
                        and the less frequently locks need to be acquired.
                        For more information see Documentation/vm/slub.txt.

        slub_min_order= [MM, SLUB]
                        Determines the minimum page order for slabs. Must be
                        lower than slub_max_order.
                        For more information see Documentation/vm/slub.txt.

        slub_nomerge    [MM, SLUB]
                        Same with slab_nomerge. This is supported for legacy.
                        See slab_nomerge for more information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
