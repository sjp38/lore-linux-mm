Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BD1BA90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 02:08:00 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lf10so4758242pab.18
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 23:08:00 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id fo9si5722264pdb.175.2014.10.29.23.07.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 23:07:59 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so4781106pac.30
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 23:07:59 -0700 (PDT)
Date: Thu, 30 Oct 2014 22:04:22 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same as
 normal zero page.
Message-ID: <20141030140348.GA6588@gmail.com>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
 <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
 <20141028154416.GB13840@gmail.com>
 <20141028133539.c82f5e856fd66b39c2630dd4@linux-foundation.org>
 <20141028134018.f317ed1d0bc4043cf9b4a3b7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141028134018.f317ed1d0bc4043cf9b4a3b7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, Oct 28, 2014 at 01:40:18PM -0700, Andrew Morton wrote:
> On Tue, 28 Oct 2014 13:35:39 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > Hi Andrew,
> > > Please try this patch.
> > > It passed build with/without CONFIG_TRANSPARENT_HUGEPAGE. Thanks.
> > 
> > You didn't answer my question.
> 
> Ah, yes you did, in another email, sorry.
> 
> I see Kirill has a different patch for you to review and test.

I tested Kirill's patch and it worked OK. His patch makes more sense as
well because it removes the old hack. Please include his patch and drop
mine. Thanks.

Regards
Yin, Fengwei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
