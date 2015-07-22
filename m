Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3850F9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 17:43:11 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so119575607qkf.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:43:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f61si3237375qgf.106.2015.07.22.14.43.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 14:43:10 -0700 (PDT)
Date: Wed, 22 Jul 2015 23:41:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv2 0/6] Make vma_is_anonymous() reliable
Message-ID: <20150722214115.GA20872@redhat.com>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com> <20150721221429.GA7478@node.dhcp.inet.fi> <20150721163957.c83e5feb8239d2081d8a7489@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150721163957.c83e5feb8239d2081d8a7489@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/21, Andrew Morton wrote:
>
> On Wed, 22 Jul 2015 01:14:29 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
> > ping?
>
> Oleg, he's pinging you.

Me? ;)

I think this series is fine. I was silent because I think my
opinion is not importand when it comes to changes in mm/.

FWIW,

Reviewed-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
