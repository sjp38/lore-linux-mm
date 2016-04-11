Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 589AC6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 17:27:43 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n1so131402921pfn.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:27:43 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id q90si5595548pfa.198.2016.04.11.14.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 14:27:42 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id ot11so45257260pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:27:42 -0700 (PDT)
Message-ID: <1460410060.6473.574.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Apr 2016 14:27:40 -0700
In-Reply-To: <20160411222309.499a2125@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
	 <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160409111132.781a11b6@redhat.com>
	 <1460205278.6473.486.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160411222309.499a2125@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lsf@lists.linux-foundation.org, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, 2016-04-11 at 22:23 +0200, Jesper Dangaard Brouer wrote:

> If we have a page-pool recycle facility, then we could use the trick,
> right? (As we know that get_page_unless_zero() cannot happen for pages
> in the pool).

Well, if you disable everything that possibly use
get_page_unless_zero(), I guess this could work.

But then, you'll have to spy lkml traffic forever to make sure no new
feature is added in the kernel, using this get_page_unless_zero() in a
new clever way.

You could use a page flag so that z BUG() triggers if
get_page_unless_zero() is attempted on one of your precious pages ;)\

We had very subtle issues before my fixes (check
35b7a1915aa33da812074744647db0d9262a555c and children), so I would not
waste time on the lock prefix avoidance at this point.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
