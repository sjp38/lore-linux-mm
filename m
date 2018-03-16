Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0E3B6B000D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:33:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t23-v6so796668ply.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:33:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n81si6190307pfb.320.2018.03.16.14.33.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:33:08 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:33:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add config for readahead window
Message-Id: <20180316143306.dd98055a170497e9535cc176@linux-foundation.org>
In-Reply-To: <20180316182512.118361-1-wvw@google.com>
References: <20180316182512.118361-1-wvw@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wvw@google.com>
Cc: gregkh@linuxfoundation.org, toddpoynor@google.com, wei.vince.wang@gmail.com, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 16 Mar 2018 11:25:08 -0700 Wei Wang <wvw@google.com> wrote:

> Change VM_MAX_READAHEAD value from the default 128KB to a configurable
> value. This will allow the readahead window to grow to a maximum size
> bigger than 128KB during boot, which could benefit to sequential read
> throughput and thus boot performance.

You can presently run ioctl(BLKRASET) against the block device?
