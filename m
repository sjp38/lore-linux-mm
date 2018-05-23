Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C266F6B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:52:26 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d4-v6so13832571plr.17
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:52:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1-v6si18224755pld.188.2018.05.23.02.52.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 02:52:25 -0700 (PDT)
Date: Wed, 23 May 2018 11:52:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Message-ID: <20180523095220.GN20441@dhcp22.suse.cz>
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
 <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
 <20180522175836.GB1237@bombadil.infradead.org>
 <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
 <20180523063439.GD20441@dhcp22.suse.cz>
 <e76d4238-9cfe-1f0f-0a52-cfaf476380a8@virtuozzo.com>
 <20180523092515.GL20441@dhcp22.suse.cz>
 <c6501d68-2f53-7bfa-6065-785df0c63de2@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6501d68-2f53-7bfa-6065-785df0c63de2@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Wed 23-05-18 12:28:10, Andrey Ryabinin wrote:
> On 05/23/2018 12:25 PM, Michal Hocko wrote:
> > OK, so the point seems to be to share large physically contiguous memory
> > with userspace.
> > 
> 
> Not physically, but virtually contiguous.

Ble, you are right! That's what I meant...

-- 
Michal Hocko
SUSE Labs
