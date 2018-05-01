Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id E96A96B0007
	for <linux-mm@kvack.org>; Tue,  1 May 2018 12:48:55 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id i16-v6so8421024ybk.21
        for <linux-mm@kvack.org>; Tue, 01 May 2018 09:48:55 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id y126-v6si177647vkf.308.2018.05.01.09.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 09:48:55 -0700 (PDT)
Date: Tue, 1 May 2018 11:48:53 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
In-Reply-To: <20180430202247.25220-8-willy@infradead.org>
Message-ID: <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
References: <20180430202247.25220-1-willy@infradead.org> <20180430202247.25220-8-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Mon, 30 Apr 2018, Matthew Wilcox wrote:

> Use page->private instead, now that these two fields are in the same
> location.  Include a compile-time assert that the fields don't get out
> of sync.

Hrm. This makes the source code a bit less readable. Guess its ok.

Acked-by: Christoph Lameter <cl@linux.com>
