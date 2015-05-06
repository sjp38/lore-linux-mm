Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 04EBA6B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 19:29:18 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so23478657pdb.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 16:29:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cz2si326634pad.93.2015.05.06.16.29.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 16:29:17 -0700 (PDT)
Date: Wed, 6 May 2015 16:29:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Find mirrored memory, use for boot time allocations
Message-Id: <20150506162916.d19f9d82cecd0d96897d7835@linux-foundation.org>
In-Reply-To: <cover.1430772743.git.tony.luck@intel.com>
References: <cover.1430772743.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 4 May 2015 13:52:23 -0700 Tony Luck <tony.luck@intel.com> wrote:

> UEFI published the spec that descibes the attribute bit we need to
> find out which memory ranges are mirrored. So time to post the real
> version of this series.

Can we please have an explanation for why we're doing this?  Reading
further I see that the intent is to put kernel data structures into
mirrored memory.  Why is this a good thing?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
