Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82C176B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:45:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so49228785pfb.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 10:45:25 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id qi7si35303533pac.183.2016.09.20.10.45.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 10:45:24 -0700 (PDT)
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57E175B3.1040802@linux.intel.com>
Date: Tue, 20 Sep 2016 10:45:23 -0700
MIME-Version: 1.0
In-Reply-To: <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On 09/20/2016 10:37 AM, Mike Kravetz wrote:
> 
> Their approach (I believe) would be to fail the offline operation in
> this case.  However, I could argue that failing the operation, or
> dissolving the unused huge page containing the area to be offlined is
> the right thing to do.

I think the right thing to do is dissolve the whole huge page if even a
part of it is offlined.  The only question is what to do with the
gigantic remnants.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
