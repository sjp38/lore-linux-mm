Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E64226B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 01:52:51 -0400 (EDT)
Received: by obhx4 with SMTP id x4so16586117obh.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 22:52:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1208011259550.4606@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com>
 <1343411703-2720-4-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207271550190.25434@router.home>
 <CAAmzW4MdiJOaZW_b+fz1uYyj0asTCveN=24st4xKymKEvkzdgQ@mail.gmail.com>
 <alpine.DEB.2.00.1207301425410.28838@router.home> <CAHO5Pa0wwSi3VH1ytLZsEJs99i_=5qN5ax=8y=uz1jbG+P03sw@mail.gmail.com>
 <alpine.DEB.2.00.1208011259550.4606@router.home>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Thu, 2 Aug 2012 07:52:30 +0200
Message-ID: <CAHO5Pa2LhC2YxVtGguVc5Ppts7pGAGRD47L41OzGjJ+a9DfZaQ@mail.gmail.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value of
 move_pages() syscall
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: JoonSoo Kim <js1304@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>

On Wed, Aug 1, 2012 at 8:00 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 1 Aug 2012, Michael Kerrisk wrote:
>
>> Is the patch below acceptable? (I've attached the complete page as well.)
>
> Yes looks good.

Thanks for checking it!

>> See you in San Diego (?),
>
> Yup. I will be there too.

See you then!

Cheers,

Michael

-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
