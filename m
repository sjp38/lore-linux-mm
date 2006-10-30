Received: by ug-out-1314.google.com with SMTP id o4so1033476uge
        for <linux-mm@kvack.org>; Mon, 30 Oct 2006 06:32:57 -0800 (PST)
Message-ID: <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com>
Date: Mon, 30 Oct 2006 16:32:57 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 1/3]: leak tracking for kmalloc node
In-Reply-To: <20061030141454.GB7164@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061030141454.GB7164@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 10/30/06, Christoph Hellwig <hch@lst.de> wrote:
> If we want to use the node-aware kmalloc in __alloc_skb we need
> the tracker is responsible for leak tracking magic for it.  This
> patch implements it.  The code is far too ugly for my taste, but it's
> doing exactly what the regular kmalloc is doing and thus follows it's
> style.

Yeah, the allocation paths are ugly. If only someone with NUMA machine
could give this a shot so we can get it merged:

http://marc.theaimsgroup.com/?l=linux-kernel&m=115952740803511&w=2

Should clean up NUMA kmalloc tracking too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
