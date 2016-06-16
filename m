Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A56CC6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 16:03:13 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id f10so922234obr.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 13:03:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 81si7577926pfw.133.2016.06.16.13.03.12
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 13:03:12 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Date: Thu, 16 Jun 2016 20:03:08 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023FB51E@IRSMSX103.ger.corp.intel.com>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com> <20160608160653.GB21838@dhcp22.suse.cz>
 <575848F9.2060501@intel.com> <20160609122140.GE24777@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023FB491@IRSMSX103.ger.corp.intel.com>
 <20160616181912.GQ6836@dhcp22.suse.cz>
In-Reply-To: <20160616181912.GQ6836@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "mingli199x@qq.com" <mingli199x@qq.com>, "minchan@kernel.org" <minchan@kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On Thu 16-06-16 08:19 PM, Michal Hocko wrote:
>
> On Thu 16-06-16 18:08:57, Odzioba, Lukasz wrote:
> I am not able to find clear reasons why we shouldn't do it for the rest.
> Ok so what do we do now? I'll send v2 with proposed changes.
> Then do we still want  to have stats on those pvecs?
> In my opinion it's not worth it now.
>
> I think the fix has a higher priority - we also want to backport it to
> stable trees IMO. We can discuss the stats and how to present them
> later.

Will send the patch tomorrow. In the meantime I was able get similar
problem on lru_deactivate by using MADV_FREE:

LRU_add              588 =3D    18704kB
LRU_rotate             0 =3D        0kB
LRU_deactivate       165 =3D   309304kB
LRU_deact_file         0 =3D        0kB
LRU_activate           0 =3D        0kB

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
