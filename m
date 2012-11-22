Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 562AF6B0062
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 03:52:19 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id m15so5239599lah.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 00:52:17 -0800 (PST)
Date: Thu, 22 Nov 2012 10:52:15 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [RFC 3/3] man-pages: Add man page for vmpressure_fd(2)
In-Reply-To: <20121121113920.0f0672b1.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.02.1211221051130.2205@tux.localdomain>
References: <20121107105348.GA25549@lizard> <20121107110152.GC30462@lizard> <20121119215211.6370ac3b.akpm@linux-foundation.org> <20121120062400.GA9468@lizard> <alpine.DEB.2.00.1211201004390.4200@chino.kir.corp.google.com> <20121121150149.GE8218@suse.de>
 <20121121113920.0f0672b1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, 21 Nov 2012, Andrew Morton wrote:
> The proposed API bugs me a bit.  It seems simplistic.  I need to have a
> quality think about this.  Maybe the result of that think will be to
> suggest an interface which can be extended in a back-compatible fashion
> later on, if/when the simplistic nature becomes a problem.

That's exactly why I made a generic vmevent_fd() syscall, not a 'vm 
pressure' specific ABI.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
