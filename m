Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63D926B0010
	for <linux-mm@kvack.org>; Fri,  4 May 2018 16:52:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u10-v6so4739185pgp.8
        for <linux-mm@kvack.org>; Fri, 04 May 2018 13:52:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 64-v6si16042625ply.528.2018.05.04.13.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 13:52:51 -0700 (PDT)
Date: Fri, 4 May 2018 13:52:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 00/17] Rearrange struct page
Message-Id: <20180504135249.676650d27bb3959838119567@linux-foundation.org>
In-Reply-To: <20180504183318.14415-1-willy@infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>

On Fri,  4 May 2018 11:33:01 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> As presented at LSFMM, this patch-set rearranges struct page to give
> more contiguous usable space to users who have allocated a struct page
> for their own purposes.

Are there such users?  Why is this considered useful? etc.
