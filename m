Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A88F6B026C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 11:01:56 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c73so21520481qke.2
        for <linux-mm@kvack.org>; Mon, 07 May 2018 08:01:56 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id t68si6798638qki.258.2018.05.07.08.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 08:01:55 -0700 (PDT)
Date: Mon, 7 May 2018 10:01:53 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v5 16/17] slub: Remove 'reserved' file from sysfs
In-Reply-To: <20180504183318.14415-17-willy@infradead.org>
Message-ID: <alpine.DEB.2.21.1805071001310.23585@nuc-kabylake>
References: <20180504183318.14415-1-willy@infradead.org> <20180504183318.14415-17-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Fri, 4 May 2018, Matthew Wilcox wrote:

> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> Christoph doubts anyone was using the 'reserved' file in sysfs, so
> remove it.

Acked-by: Christoph Lameter <cl@linux.com>
