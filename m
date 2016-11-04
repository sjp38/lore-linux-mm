Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27F196B0323
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 10:57:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r68so18534513wmd.0
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:57:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 7si5512304wmr.108.2016.11.04.07.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 07:57:22 -0700 (PDT)
Date: Fri, 4 Nov 2016 10:57:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] swapfile: fix memory corruption via malformed swapfile
Message-ID: <20161104145704.GB8825@cmpxchg.org>
References: <1477949533-2509-1-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477949533-2509-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 31, 2016 at 10:32:13PM +0100, Jann Horn wrote:
> When root activates a swap partition whose header has the wrong endianness,
> nr_badpages elements of badpages are swabbed before nr_badpages has been
> checked, leading to a buffer overrun of up to 8GB.
> 
> This normally is not a security issue because it can only be exploited by
> root (more specifically, a process with CAP_SYS_ADMIN or the ability to
> modify a swap file/partition), and such a process can already e.g. modify
> swapped-out memory of any other userspace process on the system.
> 
> Testcase for reproducing the bug (must be run as root, should crash your
> kernel):
[...]
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jann@thejh.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
