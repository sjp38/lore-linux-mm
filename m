Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 489036B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 16:16:45 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so87688299pac.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 13:16:45 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id vx8si6623232pac.107.2016.05.04.13.16.44
        for <linux-mm@kvack.org>;
        Wed, 04 May 2016 13:16:44 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <572A58AB.6090106@intel.com>
Date: Wed, 4 May 2016 13:16:43 -0700
MIME-Version: 1.0
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 05/04/2016 12:41 PM, Odzioba, Lukasz wrote:
> Do you see any advantages of dropping THP from pagevecs over this solution?

It's a more foolproof solution.  Even with this patch, there might still
be some corner cases where the draining doesn't occur.  That "two
minutes" might be come 20 or 200 under some circumstances.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
