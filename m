Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D64B96B0038
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:55:03 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so77476129wib.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:55:03 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id i2si43528296wjz.123.2015.07.21.16.55.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:55:02 -0700 (PDT)
Received: by wicgb10 with SMTP id gb10so74790332wic.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:55:02 -0700 (PDT)
Date: Wed, 22 Jul 2015 02:54:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/6] Make vma_is_anonymous() reliable
Message-ID: <20150721235458.GA7711@node.dhcp.inet.fi>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150721221429.GA7478@node.dhcp.inet.fi>
 <20150721163957.c83e5feb8239d2081d8a7489@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150721163957.c83e5feb8239d2081d8a7489@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 21, 2015 at 04:39:57PM -0700, Andrew Morton wrote:
> On Wed, 22 Jul 2015 01:14:29 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > ping?
> 
> Oleg, he's pinging you.
> 
> (It's only been 4 days, two of which were weekend.

I thought the patchset is trivial enough to hit fast-track...

But, fair enough.

> Go review someone's 20-patch series if you want to speed things up ;))

Which one? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
