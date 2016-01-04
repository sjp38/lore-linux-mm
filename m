Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1C406B0006
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 15:47:30 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b14so184439wmb.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 12:47:30 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id v10si586121wmd.0.2016.01.04.12.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 12:47:29 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l65so152814wmf.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 12:47:29 -0800 (PST)
Date: Mon, 4 Jan 2016 22:47:27 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: pagewalk API
Message-ID: <20160104204727.GE13515@node.shutemov.name>
References: <20160104182939.GA27351@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104182939.GA27351@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org

On Mon, Jan 04, 2016 at 01:29:39PM -0500, Matthew Wilcox wrote:
> 
> I find myself in the position of needing to expand the pagewalk API to
> allow PUDs to be passed to pagewalk handlers.
> 
> The problem with the current pagewalk API is that it requires the callers
> to implement a lot of boilerplate, and the further up the hierarchy we
> intercept the pagewalk, the more boilerplate has to be implemented in each
> caller, to the point where it's not worth using the pagewalk API any more.
> 
> Compare and contrast mincore's pud_entry that only has to handle PUDs
> which are guaranteed to be (1) present, (2) huge, (3) locked versus the
> PMD code which has to take care of checking all three things itself.
> 
> (http://marc.info/?l=linux-mm&m=145097405229181&w=2)
> 
> Kirill's point is that it's confusing to have the PMD and PUD handling
> be different, and I agree.  But it certainly saves a lot of code in the
> callers.  So should we convert the PMD code to be similar?  Or put a
> subptimal API in for the PUD case?

Naoya, if I remember correctly, we had something like this on early stage
of you pagewalk rework. Is it correct? If yes, why it was changed to what
we have now?

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
