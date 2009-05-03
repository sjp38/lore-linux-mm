Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 23CCA6B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 22:09:36 -0400 (EDT)
Date: Sat, 2 May 2009 22:08:29 -0400
From: Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH 1/6] ksm: limiting the num of mem regions user can
 register per fd.
Message-ID: <20090502220829.392b7ff9@riellaptop.surriel.com>
In-Reply-To: <1241302572-4366-2-git-send-email-ieidus@redhat.com>
References: <1241302572-4366-1-git-send-email-ieidus@redhat.com>
	<1241302572-4366-2-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Sun,  3 May 2009 01:16:07 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> Right now user can open /dev/ksm fd and register unlimited number of
> regions, such behavior may allocate unlimited amount of kernel memory
> and get the whole host into out of memory situation.

How many times can a process open /dev/ksm?

If a process can open /dev/ksm a thousand times and then
register 1000 regions through each file descriptor, this
patch does not help all that much...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
