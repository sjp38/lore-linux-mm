Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BD09B6B0069
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:10:44 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so2236323pad.12
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:10:44 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tr4si21337201pab.208.2013.12.02.18.10.42
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:10:43 -0800 (PST)
Date: Tue, 3 Dec 2013 11:13:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/5] slab: make more slab management structure off the
 slab
Message-ID: <20131203021308.GE31168@lge.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385974183-31423-6-git-send-email-iamjoonsoo.kim@lge.com>
 <00000142b3d18433-eacdc401-434f-42e1-8988-686bd15a3e20-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142b3d18433-eacdc401-434f-42e1-8988-686bd15a3e20-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 02, 2013 at 02:58:41PM +0000, Christoph Lameter wrote:
> On Mon, 2 Dec 2013, Joonsoo Kim wrote:
> 
> > Now, the size of the freelist for the slab management diminish,
> > so that the on-slab management structure can waste large space
> > if the object of the slab is large.
> 
> Hmmm.. That is confusing to me. "Since the size of the freelist has shrunk
> significantly we have to adjust the heuristic for making the on/off slab
> placement decision"?
> 
> Make this clearer.

Yes. your understanding is right.
I will replace above line with yours.

Thanks.

> 
> Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
