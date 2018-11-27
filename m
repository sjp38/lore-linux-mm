Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6036B48A6
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 10:20:29 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id g3so3715332wmf.1
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 07:20:29 -0800 (PST)
Received: from unicorn.mansr.com (unicorn.mansr.com. [2001:8b0:ca0d:8d8e::2])
        by mx.google.com with ESMTPS id q184-v6si3323643wma.41.2018.11.27.07.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 07:20:27 -0800 (PST)
From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] mm: fix insert_pfn() return value
References: <20181127144351.9137-1-mans@mansr.com>
	<20181127150852.GA10377@bombadil.infradead.org>
Date: Tue, 27 Nov 2018 15:20:24 +0000
In-Reply-To: <20181127150852.GA10377@bombadil.infradead.org> (Matthew Wilcox's
	message of "Tue, 27 Nov 2018 07:08:52 -0800")
Message-ID: <yw1x8t1elf7r.fsf@mansr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Matthew Wilcox <willy@infradead.org> writes:

> On Tue, Nov 27, 2018 at 02:43:51PM +0000, Mans Rullgard wrote:
>> Commit 9b5a8e00d479 ("mm: convert insert_pfn() to vm_fault_t") accidenta=
lly
>> made insert_pfn() always return an error.  Fix this.
>
> Umm.  VM_FAULT_NOPAGE is not an error.  It's saying "I inserted the PFN,
> there's no struct page for the core VM to do anything with".  Which is
> the correct response from a device driver which has called insert_pfn().
>
> Could you explain a bit more what led you to think there's a problem here?

Apparently some (not in mainline) driver code had been hastily converted
to the vm_fault_t codes, and that is where the error is.  Sorry for the
noise.  Please disregard this.

(The quickest way to get the correct answer is still to send a bad
patch.)

> Also, rather rude of you not to cc the patch author when you claim to
> be fixing a bug in their patch.

Sorry about that.  Blame the get-maintainers script.

--=20
M=E5ns Rullg=E5rd
