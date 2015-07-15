Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 708DB28029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:55:00 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so37807122ieb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:55:00 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id lq3si11489296igb.3.2015.07.15.09.54.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 09:54:59 -0700 (PDT)
Date: Wed, 15 Jul 2015 11:54:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slub: extend slowpath __slab_free() to handle bulk
 free
In-Reply-To: <20150715160119.17525.53567.stgit@devil>
Message-ID: <alpine.DEB.2.11.1507151153110.8615@east.gentwo.org>
References: <20150715155934.17525.2835.stgit@devil> <20150715160119.17525.53567.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>

On Wed, 15 Jul 2015, Jesper Dangaard Brouer wrote:

> This allows a list of object to be free'ed using a single locked
> cmpxchg_double.

Well not really. The objects that are to be freed on the list have
additional requirements. They must all be objects from the *same* slab
page. This needs to be pointed out everywhere otherwise people will try to free
random objects via this function and we will have weird failure cases.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
