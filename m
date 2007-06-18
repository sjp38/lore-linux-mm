Received: by wa-out-1112.google.com with SMTP id m33so2409152wag
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:26:42 -0700 (PDT)
Message-ID: <84144f020706181326i6923cccdm21d122ee9eee8fb7@mail.gmail.com>
Date: Mon, 18 Jun 2007 23:26:41 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <84144f020706181316u70145db2i786641d265e5bc42@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095914.622685354@sgi.com>
	 <84144f020706181316u70145db2i786641d265e5bc42@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> Hmm, did you check kernel text size before and after this change?
> Setting the __GFP_ZERO flag at every kzalloc call-site seems like a
> bad idea.

Aah but most call-sites, of course, use constants such as GFP_KERNEL
only which should be folded nicely by the compiler. So this probably
doesn't have much impact. Would be nice if you'd check, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
