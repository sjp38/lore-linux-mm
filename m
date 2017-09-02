Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 948256B025F
	for <linux-mm@kvack.org>; Sat,  2 Sep 2017 09:35:17 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t13so5117861qtc.7
        for <linux-mm@kvack.org>; Sat, 02 Sep 2017 06:35:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i1si1227569qkf.452.2017.09.02.06.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Sep 2017 06:35:16 -0700 (PDT)
Date: Sat, 2 Sep 2017 15:35:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01/13] dax: update to new mmu_notifier semantic
Message-ID: <20170902133513.GB26026@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
 <20170831211738.17922-2-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170831211738.17922-2-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 31, 2017 at 05:17:26PM -0400, Jerome Glisse wrote:
> +		if (start && end) {

"&& end" can be dropped from above and the other places but it can be
optimized later..

Thanks,
Andrea 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
