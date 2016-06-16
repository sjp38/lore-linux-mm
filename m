Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFAE26B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:19:15 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so30664901lbc.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:19:15 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id d87si18240490wmh.76.2016.06.16.11.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 11:19:14 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id k184so33626147wme.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:19:14 -0700 (PDT)
Date: Thu, 16 Jun 2016 20:19:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Message-ID: <20160616181912.GQ6836@dhcp22.suse.cz>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com>
 <20160608160653.GB21838@dhcp22.suse.cz>
 <575848F9.2060501@intel.com>
 <20160609122140.GE24777@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023FB491@IRSMSX103.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023FB491@IRSMSX103.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "mingli199x@qq.com" <mingli199x@qq.com>, "minchan@kernel.org" <minchan@kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On Thu 16-06-16 18:08:57, Odzioba, Lukasz wrote:
> On Thru 09-06-16 02:22 PM Michal Hocko wrote:
> > I agree it would be better to do the same for others as well. Even if
> > this is not an immediate problem for those.
> 
> I am not able to find clear reasons why we shouldn't do it for the rest.
> Ok so what do we do now? I'll send v2 with proposed changes.
> Then do we still want  to have stats on those pvecs?
> In my opinion it's not worth it now.

I think the fix has a higher priority - we also want to backport it to
stable trees IMO. We can discuss the stats and how to present them
later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
