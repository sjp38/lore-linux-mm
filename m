Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9A2E280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 00:43:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so144537860pfb.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 21:43:04 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id j67si12453pfg.62.2016.09.21.21.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 21:43:04 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id oz2so25164626pac.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 21:43:04 -0700 (PDT)
Date: Thu, 22 Sep 2016 14:42:56 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] percpu: improve generic percpu modify-return
 implementation
Message-ID: <20160922144256.1b9d98c6@roar.ozlabs.ibm.com>
In-Reply-To: <alpine.DEB.2.20.1609211514440.18800@east.gentwo.org>
References: <20160921085137.862-1-npiggin@gmail.com>
	<20160921205711.4e804777@roar.ozlabs.ibm.com>
	<20160921142343.GA10734@htj.duckdns.org>
	<alpine.DEB.2.20.1609211514440.18800@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Wed, 21 Sep 2016 15:16:25 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Wed, 21 Sep 2016, Tejun Heo wrote:
> 
> > Hello, Nick.
> >
> > How have you been? :)
> >  
> 
> He is baack. Are we getting SL!B? ;-)
> 

Hey Christoph. Sure, why not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
