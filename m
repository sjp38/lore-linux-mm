Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7AF6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:10:54 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c3so13337200wrd.0
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:10:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si14158925wrh.357.2017.12.20.07.10.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 07:10:53 -0800 (PST)
Date: Wed, 20 Dec 2017 16:10:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 0/9] memfd: add sealing to hugetlb-backed memory
Message-ID: <20171220151051.GV4831@dhcp22.suse.cz>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
 <aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com>
 <CAJ+F1CJCbmUHSMfKou_LP3eMq+p-b7S9vbe1Vv=JsGMFr7bk_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJ+F1CJCbmUHSMfKou_LP3eMq+p-b7S9vbe1Vv=JsGMFr7bk_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@gmail.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com, Andrew Morton <akpm@linux-foundation.org>, David Herrmann <dh.herrmann@gmail.com>

On Wed 20-12-17 15:15:50, Marc-Andre Lureau wrote:
> Hi
> 
> On Wed, Nov 15, 2017 at 4:13 AM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> > +Cc: Andrew, Michal, David
> >
> > Are there any other comments on this patch series from Marc-Andre?  Is anything
> > else needed to move forward?
> >
> > I have reviewed the patches in the series.  David Herrmann (the original
> > memfd_create/file sealing author) has also taken a look at the patches.
> >
> > One outstanding issue is sorting out the config option dependencies.  Although,
> > IMO this is not a strict requirement for this series.  I have addressed this
> > issue in a follow on series:
> > http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.com
> 
> Are we good for the next merge window? Is Hugh Dickins the maintainer
> with the final word, and doing the pull request? (sorry, I am not very
> familiar with kernel development)

Andrew will pick it up, I assume. I will try to get and review this but
there is way too much going on before holiday.

If Mieke feels sufficiently confident about this then I won't object to
the go ahead.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
