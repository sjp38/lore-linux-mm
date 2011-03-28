Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 112448D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:29:22 -0400 (EDT)
Received: by pxi10 with SMTP id 10so862120pxi.8
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 08:29:18 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH 0/2] ksm: take dirty bit as reference to avoid volatile pages
Date: Mon, 28 Mar 2011 23:29:03 +0800
References: <201103282214.19345.nai.xia@gmail.com> <4D90A236.9030200@ravellosystems.com>
In-Reply-To: <4D90A236.9030200@ravellosystems.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201103282329.04184.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Chris Wright <chrisw@sous-sol.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Monday 28 March 2011 22:59:02 Izik Eidus wrote:
> On 03/28/2011 04:14 PM, Nai Xia wrote:
> > Currently, ksm uses page checksum to detect volatile pages. Izik Eidus
> > suggested that we could use pte dirty bit to optimize. This patch series
> > adds this new logic.
> >
> 
> Hi,
> 
> One small note:
> When kvm will use ksm on intel cpu with extended page tables support, 
> the cpu won`t track
> dirty bit, therefore the calc_hash() logic should be used in such cases
> (untill intel will fadd this support in their cpus)...
> 
> Moreover I think that even though that AMD nested page tables does 
> update dirty bit, you still need
> to sync it with the host page table using mmu notifiers ?
> 
> (Not that on regular application use case of ksm any of this should be 
> an issue)
> 
> 

Hmm, I will consider these two issues in the next version. Thanks for
input!


Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
