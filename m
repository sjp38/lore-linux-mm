Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF916B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 14:08:59 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so1668463qaq.15
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 11:08:59 -0700 (PDT)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id s4si5989599qay.65.2014.07.23.11.08.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 11:08:58 -0700 (PDT)
Received: by mail-qa0-f51.google.com with SMTP id k15so1674015qaq.10
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 11:08:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140723150608.GF1725@cmpxchg.org>
References: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
	<20140715082545.GA9366@dhcp22.suse.cz>
	<20140715121935.GB9366@dhcp22.suse.cz>
	<20140718071246.GA21565@dhcp22.suse.cz>
	<20140718144554.GG29639@cmpxchg.org>
	<CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
	<20140719173911.GA1725@cmpxchg.org>
	<20140722150825.GA4517@dhcp22.suse.cz>
	<CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
	<20140723143847.GB16721@dhcp22.suse.cz>
	<20140723150608.GF1725@cmpxchg.org>
Date: Wed, 23 Jul 2014 20:08:57 +0200
Message-ID: <CAJfpegs-k5QC+42SzLKUSaHrdPxWBaT_dF+SOPqoDvg8h5p_Tw@mail.gmail.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 23, 2014 at 5:06 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Can the new page be anything else than previous page cache?

It could be an ordinary pipe buffer too.  Stealable as well (see
generic_pipe_buf_steal()).

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
