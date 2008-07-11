Received: by rv-out-0708.google.com with SMTP id f25so4280334rvb.26
        for <linux-mm@kvack.org>; Fri, 11 Jul 2008 01:33:53 -0700 (PDT)
Message-ID: <84144f020807110133y693987e0mdeb8e90d87e46ea2@mail.gmail.com>
Date: Fri, 11 Jul 2008 11:33:53 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC PATCH 2/5] Add new GFP flag __GFP_NOTRACE.
In-Reply-To: <20080710210606.65e240f4@linux360.ro>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	 <20080710210606.65e240f4@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Thu, Jul 10, 2008 at 9:06 PM, Eduard - Gabriel Munteanu
<eduard.munteanu@linux360.ro> wrote:
> __GFP_NOTRACE turns off allocator tracing for that particular allocation.
>
> This is used by kmemtrace to correctly classify different kinds of
> allocations, without recording one event multiple times. Example: SLAB's
> kmalloc() calls kmem_cache_alloc(), but we want to record this only as a
> kmalloc.
>
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>

I don't like this approach. I think you can just place the hooks in
the proper place in SLAB to avoid this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
