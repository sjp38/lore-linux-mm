Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82D7F6B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 19:47:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so180652426pgi.1
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 16:47:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a33si13935861pld.29.2017.01.22.16.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 16:47:03 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0N0hXud092813
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 19:47:03 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2843tyrhc4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 19:47:02 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 22 Jan 2017 17:47:02 -0700
Date: Sun, 22 Jan 2017 16:46:57 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170118110731.GA15949@linux.vnet.ibm.com>
 <20170118111201.GB29472@bombadil.infradead.org>
 <20170118221737.GP5238@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
Message-Id: <20170123004657.GT5238@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, Jan 18, 2017 at 06:00:24PM -0600, Christoph Lameter wrote:
> On Wed, 18 Jan 2017, Paul E. McKenney wrote:
> 
> > Actually, slab is using RCU to provide type safety to those slab users
> > who request it.
> 
> Typesafety is a side effect. The main idea here is that the object can
> still be accessed in RCU sections after another processor frees the
> object. We guarantee that the object is not freed but it may be reused
> for another object within the RCU period.
> 
> Can we have a name that expresses all of that properly?

But of course!!!  "Type safety".  http://wiki.c2.com/?TypeSafe

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
