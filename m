Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 615996B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:06:09 -0500 (EST)
Date: Wed, 22 Feb 2012 14:04:30 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
Message-ID: <20120222160429.GA1986@x61.redhat.com>
References: <20120222115320.GA3107@x61.redhat.com>
 <CAOJsxLGz4=2tFQdnnFmGLeFVVPq8pX5=0var7V-9+ddi=TPNVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLGz4=2tFQdnnFmGLeFVVPq8pX5=0var7V-9+ddi=TPNVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, Feb 22, 2012 at 03:17:23PM +0200, Pekka Enberg wrote:
> On Wed, Feb 22, 2012 at 1:53 PM, Rafael Aquini <aquini@redhat.com> wrote:
> > This, alongside with all other data dumped in OOM events, is very helpful
> > information in diagnosing why there was an OOM condition specially when
> > kernel code is under investigation.
> >
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> 
> Makes sense. Do you have an example how an out-of-memory slab cache
> dump looks like?
> 
Yes I do have a couple of dumps taken from some dabbler testing I was
performing. Would it be interesting to introduce a sample at the commit message, or
among the Documentation paragraphs?


> Minor style nit: just define the zeroed variables in this block.
> 
I will adjust those.

Thanks for your feedback!
-- 
Rafael Aquini <aquini@redhat.com>
Software Maintenance Engineer
Red Hat, Inc.
+55 51 4063.9436 / 8426138 (ext)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
