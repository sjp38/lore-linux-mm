Date: Mon, 9 Jun 2003 19:45:58 +0200 (CEST)
From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: 2.5.70-mm6
In-Reply-To: <20030607151440.6982d8c6.akpm@digeo.com>
Message-ID: <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
References: <20030607151440.6982d8c6.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> . -mm kernels will be running at HZ=100 for a while.  This is because
>   the anticipatory scheduler's behaviour may be altered by the lower
>   resolution.  Some architectures continue to use 100Hz and we need the
>   testing coverage which x86 provides.
The interactivity seems to have dropped. Again, with common desktop
applications: xmms playing with ALSA, when choosing navigating through
evolution options or browsing with opera, music skipps.
X is running with nice -10, but with mm5 it ran smoothly.

Regards,
Maciej

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
