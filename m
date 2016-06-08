Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D29D06B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:51:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so2402884pfa.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:51:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id e1si255351paz.184.2016.06.08.01.51.16
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 01:51:19 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: mm: pages are not freed from lru_add_pvecs after process
 termination
Date: Wed, 8 Jun 2016 08:51:00 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023F8B3E@IRSMSX103.ger.corp.intel.com>
References: <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
 <572CC092.5020702@intel.com> <20160511075313.GE16677@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023F84C9@IRSMSX103.ger.corp.intel.com>
 <20160607111946.GJ12305@dhcp22.suse.cz>
In-Reply-To: <20160607111946.GJ12305@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Tue 07-06-16 13:20:00, Michal Hocko wrote:
> I guess you want something like posix_memalign or start faulting in from
> an aligned address to guarantee you will fault 2MB pages.=20

Good catch.

> Besides that I am really suspicious that this will be measurable at all.
> I would just go and spin a patch assuming you are still able to trigger
> OOM with the vanilla kernel.=20

Yes, I am still able to trigger OOM, the tests I did are  more like sanity
checks rather than benchmarks. lru_cache_add takes very little time
so it was rather to look for some unexpected side effects.

Thank,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
