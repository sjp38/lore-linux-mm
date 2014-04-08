Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE5E6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 17:11:38 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id q5so7840114wiv.10
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 14:11:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fm9si1381050wjc.194.2014.04.08.14.11.35
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 14:11:36 -0700 (PDT)
Date: Tue, 8 Apr 2014 17:11:08 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 3/5] hugetlb: update_and_free_page(): don't clear
 PG_reserved bit
Message-ID: <20140408171108.4faf41b7@redhat.com>
In-Reply-To: <20140408205126.GA2778@node.dhcp.inet.fi>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
	<1396983740-26047-4-git-send-email-lcapitulino@redhat.com>
	<20140408205126.GA2778@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com

On Tue, 8 Apr 2014 23:51:26 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Apr 08, 2014 at 03:02:18PM -0400, Luiz Capitulino wrote:
> > Hugepages pages never get the PG_reserved bit set, so don't clear it. But
> > add a warning just in case.
> 
> I don't think WARN_ON() is needed. PG_reserved will be catched by
> free_pages_check().

Correct. I'll drop it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
