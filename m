Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 287A06B0062
	for <linux-mm@kvack.org>; Tue,  5 May 2009 20:54:35 -0400 (EDT)
Message-ID: <4A00DFFB.3050708@redhat.com>
Date: Tue, 05 May 2009 20:55:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] ksm: use another miscdevice minor number.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <1241475935-21162-5-git-send-email-ieidus@redhat.com> <1241475935-21162-6-git-send-email-ieidus@redhat.com> <1241475935-21162-7-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241475935-21162-7-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> The old number was registered already by another project.
> The new number is #234.
> 
> Thanks.
> 
> Signed-off-by: Izik Eidus <ieidus@redhat.com>
> Signed-off-by: Alan Cox <device@lanana.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
