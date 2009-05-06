Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E9326B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 20:40:26 -0400 (EDT)
Message-ID: <4A00DC9B.1070806@redhat.com>
Date: Tue, 05 May 2009 20:40:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] ksm: limiting the num of mem regions user can register
 per fd.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241475935-21162-2-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> Right now user can open /dev/ksm fd and register unlimited number of
> regions, such behavior may allocate unlimited amount of kernel memory
> and get the whole host into out of memory situation.
> 
> Signed-off-by: Izik Eidus <ieidus@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
