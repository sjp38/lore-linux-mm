Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51BAE6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 22:04:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l10-v6so10855976qth.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 19:04:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o64-v6si7344098qkf.305.2018.06.07.19.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 19:04:46 -0700 (PDT)
Date: Fri, 8 Jun 2018 10:04:41 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] slab: Clean up the code comment in slab kmem_cache struct
Message-ID: <20180608020441.GA16231@MiWiFi-R3L-srv>
References: <20180603032402.27526-1-bhe@redhat.com>
 <01000163d0e8083c-096b06d6-7202-4ce2-b41c-0f33784afcda-000000@email.amazonses.com>
 <20180606012624.GA19425@MiWiFi-R3L-srv>
 <01000163d7803909-286c20d2-9928-4e07-94fc-ee6552e04c67-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000163d7803909-286c20d2-9928-4e07-94fc-ee6552e04c67-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On 06/06/18 at 11:48pm, Christopher Lameter wrote:
> On Wed, 6 Jun 2018, Baoquan He wrote:
> 
> > I am back porting Thomas's sl[a|u]b freelist randomization feature to
> > our distros, need go through slab code for better understanding. From
> > git log history, they were 'obj_offset' and 'obj_size'. Later on
> > 'obj_size' was renamed to 'object_size' in commit 3b0efdfa1e("mm, sl[aou]b:
> > Extract common fields from struct kmem_cache") which is from your patch.
> > With my understanding, I guess you changed that on purpose because
> > object_size is size of each object, obj_offset is for the whole cache,
> > representing the offset the real object starts to be stored. And putting
> > them separately is for better desribing them in code comment and
> > distinction, e.g 'object_size' is in "4) cache creation/removal",
> > while 'obj_offset' is put alone to indicate it's for the whole.
> 
> obj_offset only applies when CONFIG_SLAB_DEBUG is set. Ok so that screwy
> name also indicates that something special goes on.

They are a little confusing when combine SLAB with SLUB, 

SLAB			SLUB
size                    size
object_size             object_size
obj_offset              offset

object_size also only applies when CONFIG_SLAB_DEBUG is set,
otherwise it's equal to size in SLAB case. Whereas SLUB always has
object plus freeptr for each object space.

Thought to add code comment to make them clearer, on second thought,
anyone who want to understand slab/slub code well, has to go through the
whole header file and souce code, this pain need be borne.
