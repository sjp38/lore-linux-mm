Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 555226B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 16:05:40 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id b12so1063222wgh.23
        for <linux-mm@kvack.org>; Thu, 05 Sep 2013 13:05:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130827235227.99DB95A41D6@corp2gmr1-2.hot.corp.google.com>
References: <20130827235227.99DB95A41D6@corp2gmr1-2.hot.corp.google.com>
Date: Thu, 5 Sep 2013 13:05:38 -0700
Message-ID: <CAGa+x85d-RWYPkmTVapzcYFEzPhUU7YLJHZVGK0cGc=AudYubQ@mail.gmail.com>
Subject: Re: mmotm 2013-08-27-16-51 uploaded
From: Kevin Hilman <khilman@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, vbabka@suse.cz, Olof Johansson <olof@lixom.net>

On Tue, Aug 27, 2013 at 4:52 PM,  <akpm@linux-foundation.org> wrote:

> This mmotm tree contains the following patches against 3.11-rc7:
> (patches marked "*" will be included in linux-next)

[...]

> * mm-munlock-manual-pte-walk-in-fast-path-instead-of-follow_page_mask.patch

As has already been pointed out[1], this one introduced a new warning
in -next (also lovingly acknowledged in the mmotm series file[2]) and
it seems that Vlastimil has posted an updated version[3].  Any plans
to pick up the new version for -next (or at least drop the one causing
the new warning?)

Kevin


[1] http://marc.info/?l=linux-mm&m=137764226521459&w=2
[2] http://www.ozlabs.org/~akpm/mmotm/series
[2] http://marc.info/?l=linux-mm&m=137778135631351&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
