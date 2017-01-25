Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A563F6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:07:21 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so283924915pfx.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:07:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w21si18322732pgi.98.2017.01.25.12.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 12:07:20 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PK3VWW118132
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:07:14 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 286xt3t5at-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:07:14 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 25 Jan 2017 13:07:13 -0700
Date: Wed, 25 Jan 2017 12:07:08 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170118110731.GA15949@linux.vnet.ibm.com>
 <20170118111201.GB29472@bombadil.infradead.org>
 <20170118221737.GP5238@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
 <20170123004657.GT5238@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1701251045040.983@east.gentwo.org>
 <1485363887.5145.27.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485363887.5145.27.camel@edumazet-glaptop3.roam.corp.google.com>
Message-Id: <20170125200708.GG3989@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, Jan 25, 2017 at 09:04:47AM -0800, Eric Dumazet wrote:
> On Wed, 2017-01-25 at 10:45 -0600, Christoph Lameter wrote:
> > On Sun, 22 Jan 2017, Paul E. McKenney wrote:
> > 
> > > On Wed, Jan 18, 2017 at 06:00:24PM -0600, Christoph Lameter wrote:
> > > > On Wed, 18 Jan 2017, Paul E. McKenney wrote:
> > > >
> > > > > Actually, slab is using RCU to provide type safety to those slab users
> > > > > who request it.
> > > >
> > > > Typesafety is a side effect. The main idea here is that the object can
> > > > still be accessed in RCU sections after another processor frees the
> > > > object. We guarantee that the object is not freed but it may be reused
> > > > for another object within the RCU period.
> > > >
> > > > Can we have a name that expresses all of that properly?
> > >
> > > But of course!!!  "Type safety".  http://wiki.c2.com/?TypeSafe
> > 
> > Well that does not convey the idea that RCU is involved here.
> > 
> > SLAB_DESTROY_RCU_TYPESAFE
> 
> Not clear why we need to change this very fine name ?
> 
> SLAB_DESTROY_BY_RCU was only used by few of us, we know damn well what
> it means.
> 
> Consider we wont be able to change it in various web pages / archives /
> changelogs.

The reason I proposed this change is that I ran into some people last
week who had burned some months learning that this very fine flag
provides only type safety, not identity safety.

Other proposals?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
