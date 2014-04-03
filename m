Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 876CB6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 11:33:55 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hm4so2792038wib.8
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 08:33:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u15si3704623wiv.103.2014.04.03.08.33.52
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 08:33:53 -0700 (PDT)
Date: Thu, 3 Apr 2014 17:33:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add support gigantic page allocation at
 runtime
Message-ID: <20140403153325.GM1500@redhat.com>
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Wed, Apr 02, 2014 at 02:08:44PM -0400, Luiz Capitulino wrote:
> Luiz Capitulino (4):
>   hugetlb: add hstate_is_gigantic()
>   hugetlb: update_and_free_page(): don't clear PG_reserved bit
>   hugetlb: move helpers up in the file
>   hugetlb: add support for gigantic page allocation at runtime

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
