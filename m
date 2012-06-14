Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B9FF96B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:03:30 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:03:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [00/20] Sl[auo]b: Common code rework V5 (for merge)
In-Reply-To: <4FD99D58.1060708@parallels.com>
Message-ID: <alpine.DEB.2.00.1206140903050.32075@router.home>
References: <20120613152451.465596612@linux.com> <4FD99D58.1060708@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 14 Jun 2012, Glauber Costa wrote:

> I rebased my series on top of yours, and started testing. After some
> debugging, some of the bugs were pinpointed to your code. I was going to send
> patches for it in the belief the series was already in somewhere.
>
> Since you are sending it again, I'll just point them here. If people prefer,
> to avoid having you resend the series, I'll be happy to post mine.

Yes, just post them here....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
