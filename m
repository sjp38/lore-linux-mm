Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9FCC6B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 09:50:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v189so1963729wmf.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 06:50:05 -0700 (PDT)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id b29si6685788edc.123.2018.04.05.06.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 06:50:04 -0700 (PDT)
Date: Thu, 5 Apr 2018 15:50:02 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v1 1/1] mm/ksm: fix inconsistent accounting of zero pages
Message-ID: <20180405135002.GA23486@kroah.com>
References: <1522931274-15552-1-git-send-email-imbrenda@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522931274-15552-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@kernel.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hughd@google.com, borntraeger@de.ibm.com, gerald.schaefer@de.ibm.com, stable@vger.kernel.org

On Thu, Apr 05, 2018 at 02:27:54PM +0200, Claudio Imbrenda wrote:
> When using KSM with use_zero_pages, we replace anonymous pages
> containing only zeroes with actual zero pages, which are not anonymous.
> We need to do proper accounting of the mm counters, otherwise we will
> get wrong values in /proc and a BUG message in dmesg when tearing down
> the mm.
> 
> Fixes: e86c59b1b1 ("mm/ksm: improve deduplication of zero pages with colouring")
> 
> Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> ---
>  mm/ksm.c | 7 +++++++
>  1 file changed, 7 insertions(+)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>
