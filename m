Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4EF96B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:46:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so286088361pgc.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:46:19 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i4si2921363plk.122.2017.01.25.14.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:46:18 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 194so20808862pgd.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:46:18 -0800 (PST)
Message-ID: <1485384377.5145.77.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2017 14:46:17 -0800
In-Reply-To: <20170125200708.GG3989@linux.vnet.ibm.com>
References: <20170118110731.GA15949@linux.vnet.ibm.com>
	 <20170118111201.GB29472@bombadil.infradead.org>
	 <20170118221737.GP5238@linux.vnet.ibm.com>
	 <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
	 <20170123004657.GT5238@linux.vnet.ibm.com>
	 <alpine.DEB.2.20.1701251045040.983@east.gentwo.org>
	 <1485363887.5145.27.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20170125200708.GG3989@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Christoph Lameter <cl@linux.com>, willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, 2017-01-25 at 12:07 -0800, Paul E. McKenney wrote:
> On Wed, Jan 25, 2017 at 09:04:47AM -0800, Eric Dumazet wrote:

> > 
> > Not clear why we need to change this very fine name ?
> > 
> > SLAB_DESTROY_BY_RCU was only used by few of us, we know damn well what
> > it means.
> > 
> > Consider we wont be able to change it in various web pages / archives /
> > changelogs.
> 
> The reason I proposed this change is that I ran into some people last
> week who had burned some months learning that this very fine flag
> provides only type safety, not identity safety.
> 
> Other proposals?

Bung hunting requires scrapping git log, in particular in areas touching
RCU (not exactly trivial stuff :) :) :) )

git log | grep SLAB_DESTROY_BY_RCU 

A Google search on SLAB_DESTROY_BY_RCU finds ~4600 results.

If we rename SLAB_DESTROY_BY_RCU by XXXXXXXX, someone trying to see
prior patches or articles about XXXXXXXX mistakes will find nothing.

So please leave comments giving the old name ( SLAB_DESTROY_BY_RCU ) and
save time for future hackers.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
