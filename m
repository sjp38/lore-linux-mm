Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E67776B025E
	for <linux-mm@kvack.org>; Thu, 19 May 2016 06:53:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so46992528wmw.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 03:53:30 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id wj5si8706231wjb.240.2016.05.19.03.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 03:53:29 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id n129so29508075wmn.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 03:53:29 -0700 (PDT)
Date: Thu, 19 May 2016 12:53:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: sharing page cache pages between multiple mappings
Message-ID: <20160519105328.GJ26110@dhcp22.suse.cz>
References: <CAJfpeguD-S=CEogqcDOYAYJBzfyJG=MMKyFfpMo55bQk7d0_TQ@mail.gmail.com>
 <20160519090521.GA26114@dhcp22.suse.cz>
 <CAJfpegvqPrP=AtaOSwMX1s=-oVAEE97NMwEHUkg93dBWvOykHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegvqPrP=AtaOSwMX1s=-oVAEE97NMwEHUkg93dBWvOykHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>

On Thu 19-05-16 12:17:14, Miklos Szeredi wrote:
> On Thu, May 19, 2016 at 11:05 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 19-05-16 10:20:13, Miklos Szeredi wrote:
> >> Has anyone thought about sharing pages between multiple files?
> >>
> >> The obvious application is for COW filesytems where there are
> >> logically distinct files that physically share data and could easily
> >> share the cache as well if there was infrastructure for it.
> >
> > FYI this has been discussed at LSFMM this year[1]. I wasn't at the
> > session so cannot tell you any details but the LWN article covers it at
> > least briefly.
> 
> Cool, so it's not such a crazy idea.

FWIW it is ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
