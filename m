Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 952AF6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 18:46:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r16so64265705pfg.4
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 15:46:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g2si2186620pgf.105.2016.10.21.15.46.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 15:46:33 -0700 (PDT)
Date: Sat, 22 Oct 2016 01:46:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv4] shmem: avoid huge pages for small files
Message-ID: <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com>
References: <20161021185103.117938-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161021185103.117938-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 21, 2016 at 09:51:03PM +0300, Kirill A. Shutemov wrote:
> +		case SHEME_HUGE_ALWAYS:

Oops. Forgot to commit the fixup :-/
