Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 56AEA6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 14:29:45 -0400 (EDT)
Message-ID: <51E43F91.1040906@zytor.com>
Date: Mon, 15 Jul 2013 11:29:37 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
References: <1373594635-131067-1-git-send-email-holt@sgi.com> <1373594635-131067-5-git-send-email-holt@sgi.com> <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com> <20130715174551.GA58640@asylum.americas.sgi.com> <51E4375E.1010704@zytor.com> <20130715182615.GF3421@sgi.com>
In-Reply-To: <20130715182615.GF3421@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On 07/15/2013 11:26 AM, Robin Holt wrote:
> Is there a fairly cheap way to determine definitively that the struct
> page is not initialized?

By definition I would assume no.  The only way I can think of would be
to unmap the memory associated with the struct page in the TLB and
initialize the struct pages at trap time.

> I think this patch set can change fairly drastically if we have that.
> I think I will start working up those changes and code a heavy-handed
> check until I hear of an alternative way to cheaply check.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
