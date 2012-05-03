Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B12A96B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 06:52:23 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1659271lag.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 03:52:21 -0700 (PDT)
Date: Thu, 3 May 2012 13:52:11 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH v4] vmevent: Implement greater-than attribute state and
 one-shot mode
In-Reply-To: <20120501131806.GA22249@lizard>
Message-ID: <alpine.LFD.2.02.1205031351470.11258@tux.localdomain>
References: <20120418083208.GA24904@lizard> <20120418083523.GB31556@lizard> <alpine.LFD.2.02.1204182259580.11868@tux.localdomain> <20120418224629.GA22150@lizard> <alpine.LFD.2.02.1204190841290.1704@tux.localdomain> <20120419162923.GA26630@lizard>
 <20120501131806.GA22249@lizard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, 1 May 2012, Anton Vorontsov wrote:
> This patch implements a new event type, it will trigger whenever a
> value becomes greater than user-specified threshold, it complements
> the 'less-then' trigger type.
> 
> Also, let's implement the one-shot mode for the events, when set,
> userspace will only receive one notification per crossing the
> boundaries.
> 
> Now when both LT and GT are set on the same level, the event type
> works as a cross event type: it triggers whenever a value crosses
> the threshold from a lesser values side to a greater values side,
> and vice versa.
> 
> We use the event types in an userspace low-memory killer: we get a
> notification when memory becomes low, so we start freeing memory by
> killing unneeded processes, and we get notification when memory hits
> the threshold from another side, so we know that we freed enough of
> memory.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
