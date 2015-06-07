Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 36740900016
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 05:11:53 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so80479372pdb.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 02:11:52 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id km1si18265398pab.155.2015.06.07.02.11.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 02:11:52 -0700 (PDT)
Date: Sun, 7 Jun 2015 12:11:32 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v5 0/4] idle memory tracking
Message-ID: <20150607091132.GA1800@esperanza>
References: <cover.1431437088.git.vdavydov@parallels.com>
 <CAC4Lta1isOa+OK7mqCDjL+aV1j=mXBA8p5xnrMEMj+jy6dRMaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAC4Lta1isOa+OK7mqCDjL+aV1j=mXBA8p5xnrMEMj+jy6dRMaw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Jun 07, 2015 at 11:41:15AM +0530, Raghavendra KT wrote:
> Thanks for the patches, I was able test how the series is helpful to determine
> docker container workingset / idlemem with these patches. (tested on ppc64le
> after porting to a distro kernel).

Hi,

Thank you for using and testing it! I've been busy for a while with my
internal tasks, but I am almost done with them and will get back to this
patch set and resubmit it soon (during the next week hopefully).

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
