Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A07D06B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 15:00:12 -0400 (EDT)
Message-ID: <4A788D32.1090300@redhat.com>
Date: Tue, 04 Aug 2009 22:34:10 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/12] ksm: sysfs and defaults
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031318220.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031318220.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> At present KSM is just a waste of space if you don't have CONFIG_SYSFS=y
> to provide the /sys/kernel/mm/ksm files to tune and activate it.
>
> Make KSM depend on SYSFS?  Could do, but it might be better to provide
> some defaults so that KSM works out-of-the-box, ready for testers to
> madvise MADV_MERGEABLE, even without SYSFS.
>
> Though anyone serious is likely to want to retune the numbers to their
> taste once they have experience; and whether these settings ever reach
> 2.6.32 can be discussed along the way.  
>
> Save 1kB from tiny kernels by #ifdef'ing the SYSFS side of it.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>   

Acked-By: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
