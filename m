Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D5FC76B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 16:16:37 -0400 (EDT)
Date: Thu, 5 Sep 2013 13:17:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2013-08-27-16-51 uploaded
Message-Id: <20130905131709.2902b944.akpm@linux-foundation.org>
In-Reply-To: <CAGa+x85d-RWYPkmTVapzcYFEzPhUU7YLJHZVGK0cGc=AudYubQ@mail.gmail.com>
References: <20130827235227.99DB95A41D6@corp2gmr1-2.hot.corp.google.com>
	<CAGa+x85d-RWYPkmTVapzcYFEzPhUU7YLJHZVGK0cGc=AudYubQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, vbabka@suse.cz, Olof Johansson <olof@lixom.net>

On Thu, 5 Sep 2013 13:05:38 -0700 Kevin Hilman <khilman@linaro.org> wrote:

> On Tue, Aug 27, 2013 at 4:52 PM,  <akpm@linux-foundation.org> wrote:
> 
> > This mmotm tree contains the following patches against 3.11-rc7:
> > (patches marked "*" will be included in linux-next)
> 
> [...]
> 
> > * mm-munlock-manual-pte-walk-in-fast-path-instead-of-follow_page_mask.patch
> 
> As has already been pointed out[1], this one introduced a new warning
> in -next (also lovingly acknowledged in the mmotm series file[2]) and
> it seems that Vlastimil has posted an updated version[3].  Any plans
> to pick up the new version for -next (or at least drop the one causing
> the new warning?)
> 

yup.  I'm not here at present.  Next Tuesday I'll be back in the saddle
with a big scramble to address the known -mm bloopers and then do a
rather late merge for -rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
