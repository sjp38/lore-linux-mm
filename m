Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4476B0068
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 02:00:50 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so1970666pdi.10
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 23:00:50 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vb7si806303pbc.2.2013.12.12.23.00.47
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 23:00:49 -0800 (PST)
Date: Fri, 13 Dec 2013 16:03:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/5] slab: make more slab management structure off the
 slab
Message-ID: <20131213070351.GD8845@lge.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385974183-31423-6-git-send-email-iamjoonsoo.kim@lge.com>
 <00000142b3d18433-eacdc401-434f-42e1-8988-686bd15a3e20-000000@email.amazonses.com>
 <20131203021308.GE31168@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131203021308.GE31168@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 03, 2013 at 11:13:08AM +0900, Joonsoo Kim wrote:
> On Mon, Dec 02, 2013 at 02:58:41PM +0000, Christoph Lameter wrote:
> > On Mon, 2 Dec 2013, Joonsoo Kim wrote:
> > 
> > > Now, the size of the freelist for the slab management diminish,
> > > so that the on-slab management structure can waste large space
> > > if the object of the slab is large.
> > 
> > Hmmm.. That is confusing to me. "Since the size of the freelist has shrunk
> > significantly we have to adjust the heuristic for making the on/off slab
> > placement decision"?
> > 
> > Make this clearer.
> 
> Yes. your understanding is right.
> I will replace above line with yours.
> 
> Thanks.
> 
> > 
> > Acked-by: Christoph Lameter <cl@linux.com>

Hello, Pekka.

Below is updated patch for 5/5 in this series.
Now I get acks from Christoph to all patches in this series.
So, could you merge this patchset? :)
If you want to resend wholeset with proper ack, I will do it
with pleasure.

Thanks.

--------8<---------------
