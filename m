Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE49D6B0313
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:37:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j28so52342148pfk.14
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:37:17 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id w6si20297582pfk.420.2017.06.01.11.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:37:17 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id n23so34506064pfb.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:37:17 -0700 (PDT)
Date: Thu, 1 Jun 2017 11:37:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org>
Message-ID: <alpine.LSU.2.11.1706011128490.3622@eggly.anvils>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org>
 <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 1 Jun 2017, Christoph Lameter wrote:
> 
> Ok so debugging was off but the slab cache has a ctor callback which
> mandates that the free pointer cannot use the free object space when
> the object is not in use. Thus the size of the object must be increased to
> accomodate the freepointer.

Thanks a lot for working that out.  Makes sense, fully understood now,
nothing to worry about (though makes one wonder whether it's efficient
to use ctors on high-alignment caches; or whether an internal "zero-me"
ctor would be useful).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
