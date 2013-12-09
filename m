Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 885DE6B00AE
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 10:42:26 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id i13so2746637qae.9
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 07:42:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r5si8595867qar.3.2013.12.09.07.42.25
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 07:42:25 -0800 (PST)
Date: Mon, 9 Dec 2013 10:42:11 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: oops in pgtable_trans_huge_withdraw
Message-ID: <20131209154211.GA15701@redhat.com>
References: <20131206210254.GA7962@redhat.com>
 <20131207082117.GA17914@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131207082117.GA17914@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Sat, Dec 07, 2013 at 10:21:17AM +0200, Kirill A. Shutemov wrote:
 > On Fri, Dec 06, 2013 at 04:02:54PM -0500, Dave Jones wrote:
 > > I've spent a few days enhancing trinity's use of mmap's, trying to make it
 > > reproduce https://lkml.org/lkml/2013/12/4/499  
 > > Instead, I hit this.. related ?
 > 
 > Could you try this:
 > 
 > https://lkml.org/lkml/2013/12/4/499

I thought I had tried that on Friday, but apparently I had booted the wrong kernel.
This does seem to be the same problem. I can't reproduce the failure any more
with this patch applied.

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
