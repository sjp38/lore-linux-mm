Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 178236B00AC
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 12:46:17 -0400 (EDT)
Message-ID: <4AA53AB0.8030508@redhat.com>
Date: Mon, 07 Sep 2009 19:54:08 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] ksm: mremap use err from ksm_madvise
References: <Pine.LNX.4.64.0909052219580.7381@sister.anvils> <Pine.LNX.4.64.0909052225250.7387@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909052225250.7387@sister.anvils>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> mremap move's use of ksm_madvise() was assuming -ENOMEM on failure,
> because ksm_madvise used to say -EAGAIN for that; but ksm_madvise now
> says -ENOMEM (letting madvise convert that to -EAGAIN), and can also
> say -ERESTARTSYS when signalled: so pass the error from ksm_madvise.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>   
Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
