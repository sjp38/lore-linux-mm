Received: by ug-out-1314.google.com with SMTP id s2so50470uge
        for <linux-mm@kvack.org>; Tue, 10 Apr 2007 23:53:53 -0700 (PDT)
Message-ID: <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
Date: Wed, 11 Apr 2007 09:53:53 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
In-Reply-To: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 4/11/07, Zhao Forrest <forrest.zhao@gmail.com> wrote:
> We're using RHEL5 with kernel version 2.6.18-8.el5.
> When doing a stress test on raw device for about 3-4 hours, we found
> the soft lockup message in dmesg.
> I know we're not reporting the bug on the latest kernel, but does any
> expert know if this is the known issue in old kernel? Or why
> kmem_cache_free occupy CPU for more than 10 seconds?

Sounds like slab corruption. CONFIG_DEBUG_SLAB should tell you more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
