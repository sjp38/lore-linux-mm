Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 859D56B0034
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 12:03:49 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id z11so3082067wgg.10
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 09:03:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f9b89c37f-5d9539bc-944c-4937-9b35-30cdd0fd18a3-000000@email.amazonses.com>
References: <1372177015-30492-1-git-send-email-michael.opdenacker@free-electrons.com>
	<0000013f9b89c37f-5d9539bc-944c-4937-9b35-30cdd0fd18a3-000000@email.amazonses.com>
Date: Sun, 7 Jul 2013 19:03:47 +0300
Message-ID: <CAOJsxLEVOgSh8x+jwjJ8EwT-U1ZiYnT71s=BrM+e6i1D3ESRXA@mail.gmail.com>
Subject: Re: [PATCH] slab: add kmalloc() to kernel API documentation
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michael Opdenacker <michael.opdenacker@free-electrons.com>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 1, 2013 at 9:41 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 25 Jun 2013, Michael Opdenacker wrote:
>
>> This patch is a proposed fix for this. It also removes the documentation
>> for kmalloc() in include/linux/slob_def.h which isn't included to
>> generate the documentation anyway. This way, kmalloc() is described
>> in only one place.
>
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
