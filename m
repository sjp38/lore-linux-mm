Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6BB5A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:01:34 -0400 (EDT)
Received: by mail-ww0-f54.google.com with SMTP id 20so3833020wwd.11
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 08:01:02 -0700 (PDT)
Message-ID: <4D90A236.9030200@ravellosystems.com>
Date: Mon, 28 Mar 2011 16:59:02 +0200
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] ksm: take dirty bit as reference to avoid volatile
 pages
References: <201103282214.19345.nai.xia@gmail.com>
In-Reply-To: <201103282214.19345.nai.xia@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Chris Wright <chrisw@sous-sol.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On 03/28/2011 04:14 PM, Nai Xia wrote:
> Currently, ksm uses page checksum to detect volatile pages. Izik Eidus
> suggested that we could use pte dirty bit to optimize. This patch series
> adds this new logic.
>

Hi,

One small note:
When kvm will use ksm on intel cpu with extended page tables support, 
the cpu won`t track
dirty bit, therefore the calc_hash() logic should be used in such cases
(untill intel will fadd this support in their cpus)...

Moreover I think that even though that AMD nested page tables does 
update dirty bit, you still need
to sync it with the host page table using mmu notifiers ?

(Not that on regular application use case of ksm any of this should be 
an issue)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
