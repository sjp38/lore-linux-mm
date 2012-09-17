Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DE29E6B006C
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 02:02:33 -0400 (EDT)
Received: by ied10 with SMTP id 10so1508146ied.14
        for <linux-mm@kvack.org>; Sun, 16 Sep 2012 23:02:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384FB1E69774@EAPEX1MAIL1.st.com>
References: <1347504057-5612-1-git-send-email-lliubbo@gmail.com>
	<20120913122738.04eaceb3.akpm@linux-foundation.org>
	<CAHG8p1CJ7YizySrocYvQeCye4_63TkAimsAGU1KC5+Fn0wqF8w@mail.gmail.com>
	<D5ECB3C7A6F99444980976A8C6D896384FB1E69774@EAPEX1MAIL1.st.com>
Date: Mon, 17 Sep 2012 14:02:32 +0800
Message-ID: <CAHG8p1AwCSvWJm_xvpOOr4PAcQ6MjWgYx+RKa2i6OHPwRSkCig@mail.gmail.com>
Subject: Re: [PATCH] nommu: remap_pfn_range: fix addr parameter check
From: Scott Jiang <scott.jiang.linux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bhupesh SHARMA <bhupesh.sharma@st.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "laurent.pinchart@ideasonboard.com" <laurent.pinchart@ideasonboard.com>, "uclinux-dist-devel@blackfin.uclinux.org" <uclinux-dist-devel@blackfin.uclinux.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "gerg@uclinux.org" <gerg@uclinux.org>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>

>> I was using 3.3 linux kernel. I will again check if videobuf2 in 3.5 has already
>> fixed this issue.
>
> [snip..]
>
> Ok I just checked the vb2_dma_contig allocator and it has no major changes from my version,
> http://lxr.linux.no/linux+v3.5.3/drivers/media/video/videobuf2-dma-contig.c#L37
>
> So, I am not sure if this issue has been fixed in the videobuf2 (or if any patch is in the pipeline
> which fixes the issue).
>
I run my test on our blackfin platform, and all addresses in
remap_pfn_range is aligned for 3.5 branch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
