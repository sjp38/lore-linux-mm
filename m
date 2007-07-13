Received: by nz-out-0506.google.com with SMTP id s1so397912nze
        for <linux-mm@kvack.org>; Fri, 13 Jul 2007 02:54:55 -0700 (PDT)
Message-ID: <84144f020707130254m448b3c5bl70cfaefddb8ddc18@mail.gmail.com>
Date: Fri, 13 Jul 2007 12:54:55 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] slob: sparsemem support.
In-Reply-To: <20070713093557.GA3403@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070713093557.GA3403@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/13/07, Paul Mundt <lethal@linux-sh.org> wrote:
> Currently slob is disabled if we're using sparsemem, due to an earlier
> patch from Goto-san. Slob and static sparsemem work without any trouble
> as it is, and the only hiccup is a missing slab_is_available() in the
> case of sparsemem extreme. With this, we're rid of the last set of
> restrictions for slob usage.

Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
