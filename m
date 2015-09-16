Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 418E26B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 18:27:31 -0400 (EDT)
Received: by qgx61 with SMTP id 61so21925qgx.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 15:27:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s11si24039799qge.51.2015.09.16.15.27.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 15:27:30 -0700 (PDT)
Date: Wed, 16 Sep 2015 15:27:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/11] THP support for ARC
Message-Id: <20150916152729.15b8b5f05c82beeed599c143@linux-foundation.org>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com

On Thu, 27 Aug 2015 14:33:03 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:

> This series brings THP support to ARC. It also introduces an optional new
> thp hook for arches to possibly optimize the TLB flush in thp regime.

The mm/ changes look OK to me.  Please maintain them in the arc tree,
merge them upstream at the same time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
