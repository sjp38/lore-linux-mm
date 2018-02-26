Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79DC76B0005
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 23:35:07 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u65so7795815pfd.7
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 20:35:07 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p4si5058018pgf.656.2018.02.25.20.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Feb 2018 20:35:06 -0800 (PST)
Message-ID: <5A938F26.4040901@intel.com>
Date: Mon, 26 Feb 2018 12:37:58 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_poison: move PAGE_POISON to page_poison.c
References: <1518163694-27155-1-git-send-email-wei.w.wang@intel.com> <20180213101615.GO3443@dhcp22.suse.cz>
In-Reply-To: <20180213101615.GO3443@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On 02/13/2018 06:16 PM, Michal Hocko wrote:
> On Fri 09-02-18 16:08:14, Wei Wang wrote:
>> The PAGE_POISON macro is used in page_poison.c only, so avoid exporting
>> it. Also remove the "mm/debug-pagealloc.c" related comment, which is
>> obsolete.
> Why is this an improvement? I thought the whole point of poison.h is to
> keep all the poison value at a single place to make them obviously
> unique.

There isn't a comment explaining why they are exposed. We did this 
because PAGE_POISON is used by page_poison.c only, it seems not 
necessary to expose the private values.
Why would it be not unique if moved to page_poison.c (on condition that 
it is only used there)?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
