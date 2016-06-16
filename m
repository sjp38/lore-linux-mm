Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 233046B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:09:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 5so123203079ioy.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:09:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v7si17751128pae.206.2016.06.16.11.09.06
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 11:09:06 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Date: Thu, 16 Jun 2016 18:08:57 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023FB491@IRSMSX103.ger.corp.intel.com>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com> <20160608160653.GB21838@dhcp22.suse.cz>
 <575848F9.2060501@intel.com> <20160609122140.GE24777@dhcp22.suse.cz>
In-Reply-To: <20160609122140.GE24777@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "mingli199x@qq.com" <mingli199x@qq.com>, "minchan@kernel.org" <minchan@kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On Thru 09-06-16 02:22 PM Michal Hocko wrote:
> I agree it would be better to do the same for others as well. Even if
> this is not an immediate problem for those.

I am not able to find clear reasons why we shouldn't do it for the rest.
Ok so what do we do now? I'll send v2 with proposed changes.
Then do we still want  to have stats on those pvecs?
In my opinion it's not worth it now.

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
