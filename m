Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 179086B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 01:07:16 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id uo1so1826903pbc.17
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 22:07:15 -0700 (PDT)
Date: Thu, 27 Jun 2013 22:07:12 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628050712.GA10097@teo>
References: <20130626231712.4a7392a7@redhat.com>
 <20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
 <20130628000201.GB15637@bbox>
 <20130627173433.d0fc6ecd.akpm@linux-foundation.org>
 <20130628005852.GA8093@teo>
 <20130627181353.3d552e64.akpm@linux-foundation.org>
 <20130628043411.GA9100@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130628043411.GA9100@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu, Jun 27, 2013 at 09:34:11PM -0700, Anton Vorontsov wrote:
> ... we can add the strict mode and deprecate the
> "filtering" -- basically we'll implement the idea of requiring that
> userspace registers a separate fd for each level.

Btw, assuming that more levels can be added, there will be a problem:
imagine that an app hooked up onto low, med, crit levels in "strict"
mode... then once we add a new level, the app will start missing the new
level events.

In the old scheme it is not a problem because of the >= condition.

With a proper versioning this won't be a problem for a new scheme too.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
