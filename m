Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E06B6B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:04:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so279260802pgf.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:04:50 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id a62si23965127pge.65.2017.01.25.09.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 09:04:49 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 3so2428004pgj.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:04:49 -0800 (PST)
Message-ID: <1485363887.5145.27.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2017 09:04:47 -0800
In-Reply-To: <alpine.DEB.2.20.1701251045040.983@east.gentwo.org>
References: <20170118110731.GA15949@linux.vnet.ibm.com>
	 <20170118111201.GB29472@bombadil.infradead.org>
	 <20170118221737.GP5238@linux.vnet.ibm.com>
	 <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
	 <20170123004657.GT5238@linux.vnet.ibm.com>
	 <alpine.DEB.2.20.1701251045040.983@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, 2017-01-25 at 10:45 -0600, Christoph Lameter wrote:
> On Sun, 22 Jan 2017, Paul E. McKenney wrote:
> 
> > On Wed, Jan 18, 2017 at 06:00:24PM -0600, Christoph Lameter wrote:
> > > On Wed, 18 Jan 2017, Paul E. McKenney wrote:
> > >
> > > > Actually, slab is using RCU to provide type safety to those slab users
> > > > who request it.
> > >
> > > Typesafety is a side effect. The main idea here is that the object can
> > > still be accessed in RCU sections after another processor frees the
> > > object. We guarantee that the object is not freed but it may be reused
> > > for another object within the RCU period.
> > >
> > > Can we have a name that expresses all of that properly?
> >
> > But of course!!!  "Type safety".  http://wiki.c2.com/?TypeSafe
> 
> Well that does not convey the idea that RCU is involved here.
> 
> SLAB_DESTROY_RCU_TYPESAFE

Not clear why we need to change this very fine name ?

SLAB_DESTROY_BY_RCU was only used by few of us, we know damn well what
it means.

Consider we wont be able to change it in various web pages / archives /
changelogs.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
