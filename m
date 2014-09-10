Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8C86B00A1
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:38:45 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id o8so19853750qcw.17
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:38:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c69si20088684qge.3.2014.09.10.13.38.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 13:38:44 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:38:14 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC/PATCH v2 10/10] lib: add kasan test module
Message-ID: <20140910203814.GA10244@redhat.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-11-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410359487-31938-11-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org

On Wed, Sep 10, 2014 at 06:31:27PM +0400, Andrey Ryabinin wrote:
 > This is a test module doing varios nasty things like
 > out of bounds accesses, use after free. It is usefull for testing
 > kernel debugging features like kernel address sanitizer.
 
 > +void __init kmalloc_oob_rigth(void)
 > +{

'right' ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
