Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 0D5236B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 10:37:41 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2644131ghr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 07:37:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
References: <1335778207-6511-1-git-send-email-jack@suse.cz> <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 May 2012 10:37:20 -0400
Message-ID: <CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Jeff Moyer <jmoyer@redhat.com>, npiggin@gmail.com

> Hello,
>
> Thank you revisit this. But as far as my remember is correct, this issue is NOT
> unaligned access issue. It's just get_user_pages(_fast) vs fork race issue. i.e.
> DIRECT_IO w/ multi thread process should not use fork().

The problem is, fork (and its COW logic) assume new access makes cow break,
But page table protection can't detect a DMA write. Therefore DIO may override
shared page data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
