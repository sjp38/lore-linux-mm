Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id C91856B005D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 14:00:40 -0400 (EDT)
Date: Wed, 1 Aug 2012 13:00:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value
 of move_pages() syscall
In-Reply-To: <CAHO5Pa0wwSi3VH1ytLZsEJs99i_=5qN5ax=8y=uz1jbG+P03sw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1208011259550.4606@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com> <1343411703-2720-4-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207271550190.25434@router.home> <CAAmzW4MdiJOaZW_b+fz1uYyj0asTCveN=24st4xKymKEvkzdgQ@mail.gmail.com>
 <alpine.DEB.2.00.1207301425410.28838@router.home> <CAHO5Pa0wwSi3VH1ytLZsEJs99i_=5qN5ax=8y=uz1jbG+P03sw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1208011259552.4606@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: JoonSoo Kim <js1304@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>

On Wed, 1 Aug 2012, Michael Kerrisk wrote:

> Is the patch below acceptable? (I've attached the complete page as well.)

Yes looks good.

> See you in San Diego (?),

Yup. I will be there too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
