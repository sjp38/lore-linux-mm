Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C7FA16B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:18:07 -0400 (EDT)
Received: by qgf60 with SMTP id 60so1463622qgf.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 17:18:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x76si12109246qkx.34.2015.03.30.17.18.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 17:18:06 -0700 (PDT)
Date: Tue, 31 Mar 2015 13:17:55 +1300
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Slab infrastructure for bulk object allocation and freeing V2
Message-ID: <20150331131755.5dd5f69a@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1503300927290.6646@gentwo.org>
References: <alpine.DEB.2.11.1503300927290.6646@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com, brouer@redhat.com

On Mon, 30 Mar 2015 09:31:19 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> After all of the earlier discussions I thought it would be better to
> first get agreement on the basic way to allow implementation of the
> bulk alloc in the common slab code. So this is a revision of the initial
> proposal and it just covers the first patch.

I agree, it would be good to get the basic API in.
 
> This patch adds the basic infrastructure for alloc / free operations
> on pointer arrays. It includes a generic function in the common
> slab code that is used in this infrastructure patch to
> create the unoptimized functionality for slab bulk operations.
> 
> Allocators can then provide optimized allocation functions
> for situations in which large numbers of objects are needed.
> These optimization may avoid taking locks repeatedly and
> bypass metadata creation if all objects in slab pages
> can be used to provide the objects required.

I'll volunteer to performance benchmark the different allocators
optimized functions in this area. (I'll have time after April 13th).

 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
 
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
