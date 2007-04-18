Received: by ug-out-1314.google.com with SMTP id s2so291320uge
        for <linux-mm@kvack.org>; Tue, 17 Apr 2007 23:24:15 -0700 (PDT)
Message-ID: <84144f020704172324u725f6b22u4b1634203d65167c@mail.gmail.com>
Date: Wed, 18 Apr 2007 09:24:15 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M (v2)
In-Reply-To: <4624E8F4.2090200@sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4624E8F4.2090200@sw.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@sw.ru>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric Dumazet <dada1@cosmosbay.com>, Linux MM <linux-mm@kvack.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>
List-ID: <linux-mm.kvack.org>

On 4/17/07, Pavel Emelianov <xemul@sw.ru> wrote:
> The out_of_memory() function and SysRq-M handler call
> show_mem() to show the current memory usage state.

I am still somewhat unhappy about the spinlock, but I don't really
have a better suggestion either. Other than that, looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
