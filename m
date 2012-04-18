Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 3D2FD6B00FF
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 18:47:48 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so6742449obb.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 15:47:47 -0700 (PDT)
Date: Wed, 18 Apr 2012 15:46:32 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 2/2] vmevent: Implement greater-than attribute and
 one-shot mode
Message-ID: <20120418224629.GA22150@lizard>
References: <20120418083208.GA24904@lizard>
 <20120418083523.GB31556@lizard>
 <alpine.LFD.2.02.1204182259580.11868@tux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1204182259580.11868@tux.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Wed, Apr 18, 2012 at 11:01:02PM +0300, Pekka Enberg wrote:
> On Wed, 18 Apr 2012, Anton Vorontsov wrote:
> > This patch implements a new event type, it will trigger whenever a
> > value becomes greater than user-specified threshold, it complements
> > the 'less-then' trigger type.
> > 
> > Also, let's implement the one-shot mode for the events, when set,
> > userspace will only receive one notification per crossing the
> > boundaries.
> > 
> > Now when both LT and GT are set on the same level, the event type
> > works as a cross event type: it triggers whenever a value crosses
> > the threshold from a lesser values side to a greater values side,
> > and vice versa.
> > 
> > We use the event types in an userspace low-memory killer: we get a
> > notification when memory becomes low, so we start freeing memory by
> > killing unneeded processes, and we get notification when memory hits
> > the threshold from another side, so we know that we freed enough of
> > memory.
> > 
> > Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> 
> Did you try vmevent-test with this patch? I'm seeing this:

Yep, with CONFIG_SWAP=n, and I had to a modify the test
since I saw the same thing, I believe. I'll try w/ the swap enabled,
and see how it goes. I think the vmevent-test.c needs some improvemnts
in general, but meanwhile...

> Physical pages: 109858
> read failed: Invalid argument

Can you send me the .config file that you used? Might be that
you have CONFIG_SWAP=n too?

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
