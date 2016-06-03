Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 647326B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 03:15:56 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id x1so83185737pav.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 00:15:56 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id r86si5787937pfb.204.2016.06.03.00.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 00:15:55 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 62so10681106pfd.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 00:15:55 -0700 (PDT)
Date: Fri, 3 Jun 2016 16:15:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603071551.GA453@swordfish>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602092113.GH1995@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

Hello,

On (06/02/16 11:21), Michal Hocko wrote:
[..]
> @@ -2863,6 +2854,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>  
>  		collect_mm_slot(mm_slot);
>  	}
> +	mmput(mm);
>  
>  	return progress;
>  }

this possibly sleeping mmput() is called from
under the spin_lock(&khugepaged_mm_lock).

there is also a trivial build fixup needed
(move collect_mm_slot() before __khugepaged_exit()).


it's quite hard to trigger the bug (somehow), so I can't
follow up with more information as of now.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
