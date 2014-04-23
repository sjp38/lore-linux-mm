Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1386B0037
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 13:10:35 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so1228038ier.27
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 10:10:35 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id nx5si1028158icb.62.2014.04.23.10.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 10:10:33 -0700 (PDT)
Message-ID: <5357F405.20205@infradead.org>
Date: Wed, 23 Apr 2014 10:10:29 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
In-Reply-To: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, Luiz Capitulino <lcapitulino@redhat.com>

On 04/22/14 15:21, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-04-22-15-20 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (3.x
> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
> 

include/linux/hugetlb.h:468:9: error: 'HPAGE_SHIFT' undeclared (first use in this function)


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
