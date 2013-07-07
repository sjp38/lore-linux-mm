Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 677AC6B0034
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:47:45 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id c11so3023233wgh.1
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:47:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sun, 7 Jul 2013 18:47:43 +0300
Message-ID: <CAOJsxLEipdF=vZrDCOipcLYnpAjXOyAgWmTznRt0rsiHPRfTPA@mail.gmail.com>
Subject: Re: [PATCH] slub: do not put a slab to cpu partial list when
 cpu_partial is 0
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 19, 2013 at 9:33 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> In free path, we don't check number of cpu_partial, so one slab can
> be linked in cpu partial list even if cpu_partial is 0. To prevent this,
> we should check number of cpu_partial in put_cpu_partial().
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Applied, thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
