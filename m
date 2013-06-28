Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4A60C6B0039
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 20:58:56 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so1749001pab.3
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 17:58:55 -0700 (PDT)
Date: Thu, 27 Jun 2013 17:58:53 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628005852.GA8093@teo>
References: <20130626231712.4a7392a7@redhat.com>
 <20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
 <20130628000201.GB15637@bbox>
 <20130627173433.d0fc6ecd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130627173433.d0fc6ecd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu, Jun 27, 2013 at 05:34:33PM -0700, Andrew Morton wrote:
> > If so, userland daemon would receive lots of events which are no interest.
> 
> "lots"?  If vmpressure is generating events at such a high frequency that
> this matters then it's already busted?

Current frequency is 1/(2MB). Suppose we ended up scanning the whole
memory on a 2GB host, this will give us 1024 hits. Doesn't feel too much*
to me... But for what it worth, I am against adding read() to the
interface -- just because we can avoid the unnecessary switch into the
kernel.

* For bigger hosts we should increase the window, as we do for the vmstat. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
