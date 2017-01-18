Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B23326B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:29:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z128so34236259pfb.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 14:29:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si1464681plx.277.2017.01.18.14.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 14:29:24 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0IMSlQN035230
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:29:24 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 282f61v94m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:29:24 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 18 Jan 2017 15:29:23 -0700
Date: Wed, 18 Jan 2017 14:17:37 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170118110731.GA15949@linux.vnet.ibm.com>
 <20170118111201.GB29472@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118111201.GB29472@bombadil.infradead.org>
Message-Id: <20170118221737.GP5238@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, Jan 18, 2017 at 03:12:01AM -0800, willy@infradead.org wrote:
> On Wed, Jan 18, 2017 at 03:07:32AM -0800, Paul E. McKenney wrote:
> > A group of Linux kernel hackers reported chasing a bug that resulted
> > from their assumption that SLAB_DESTROY_BY_RCU provided an existence
> > guarantee, that is, that no block from such a slab would be reallocated
> > during an RCU read-side critical section.  Of course, that is not the
> > case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
> > slab of blocks.
> > 
> > However, there is a phrase for this, namely "type safety".  This commit
> > therefore renames SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU in order
> > to avoid future instances of this sort of confusion.
> 
> This is probably the ultimate in bikeshedding, but RCU is not the
> thing which is providing the typesafety.  Slab is providing the
> typesafety in order to help RCU.  So would a better name not be
> 'SLAB_TYPESAFETY_FOR_RCU', or more succinctly 'SLAB_RCU_TYPESAFE'?

Actually, slab is using RCU to provide type safety to those slab users
who request it.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
