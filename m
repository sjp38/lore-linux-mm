Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 1DE4A6B00D4
	for <linux-mm@kvack.org>; Tue,  7 May 2013 07:39:22 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id ea20so448929lab.30
        for <linux-mm@kvack.org>; Tue, 07 May 2013 04:39:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <517ABCF6.5040103@parallels.com>
References: <20130401103749.19027.89833.stgit@maximpc.sw.ru>
	<20130401104250.19027.27795.stgit@maximpc.sw.ru>
	<51793DE6.3000503@parallels.com>
	<CAJfpegv1zc4oeE=YXrQd0jmzVXB8jjvXkz-_4Nv_ELcvfsa74Q@mail.gmail.com>
	<517956ED.7060102@parallels.com>
	<20130425204331.GB16238@tucsk.piliscsaba.szeredi.hu>
	<517A3B98.807@parallels.com>
	<20130426140240.GC16238@tucsk.piliscsaba.szeredi.hu>
	<517ABCF6.5040103@parallels.com>
Date: Tue, 7 May 2013 13:39:19 +0200
Message-ID: <CAJfpegucNfxYsz3G2JwxK5JtDPaYQu-SUR_VGvwCDz_iTGBt5Q@mail.gmail.com>
Subject: Re: [fuse-devel] [PATCH 14/14] mm: Account for WRITEBACK_TEMP in balance_dirty_pages
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Maxim V. Patlasov" <mpatlasov@parallels.com>
Cc: Kirill Korotaev <dev@parallels.com>, Pavel Emelianov <xemul@parallels.com>, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, Mel Gorman <mgorman@suse.de>, riel@redhat.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org

On Fri, Apr 26, 2013 at 7:44 PM, Maxim V. Patlasov
<mpatlasov@parallels.com> wrote:
> I'm for accounting NR_WRITEBACK_TEMP because balance_dirty_pages is already
> overcomplicated (imho) and adding new clauses for FUSE makes me sick.

Agreed.

But instead of further complexifying balance_dirty_pages() fuse
specific throttling can be done in fuse_page_mkwrite(), I think.

And at that point NR_WRITEBACK_TEMP really becomes irrelevant to the
dirty balancing logic.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
