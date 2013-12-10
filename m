Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id D86FA6B0071
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:12:59 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so3614050yho.10
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:12:59 -0800 (PST)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id s6si13046198yho.214.2013.12.10.00.12.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 00:12:59 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id md12so7116403pbc.21
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:12:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <252512613b0823c84478428f5543d2140d1291a5.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
	<252512613b0823c84478428f5543d2140d1291a5.1386571280.git.vdavydov@parallels.com>
Date: Tue, 10 Dec 2013 12:12:57 +0400
Message-ID: <CAA6-i6rTyBtiyp9ed6DMj+U_b29Rwu7By997391WoyVxZ3YaoQ@mail.gmail.com>
Subject: Re: [PATCH v13 14/16] vmpressure: in-kernel notifications
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Dec 9, 2013 at 12:05 PM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> From: Glauber Costa <glommer@openvz.org>
>
> During the past weeks, it became clear to us that the shrinker interface

It has been more than a few weeks by now =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
