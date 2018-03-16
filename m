Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE8476B000D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 16:53:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i11so5199054pgq.10
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 13:53:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t64si5596244pgc.584.2018.03.16.13.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 13:53:45 -0700 (PDT)
Date: Fri, 16 Mar 2018 21:53:44 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: add config for readahead window
Message-ID: <20180316205344.GA6599@kroah.com>
References: <20180316182512.118361-1-wvw@google.com>
 <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wvw@google.com>
Cc: Todd Poynor <toddpoynor@google.com>, Wei Wang <wei.vince.wang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 16, 2018 at 06:49:08PM +0000, Wei Wang wrote:
> Android devices boot time benefits by bigger readahead window setting from
> init. This patch will make readahead window a config so early boot can
> benefit by it as well.

Why not put that in the changelog text?
