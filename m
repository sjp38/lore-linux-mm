Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 994C56B02C3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 19:08:10 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v76so7325021qka.5
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 16:08:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q17si1478800qkh.130.2017.07.06.16.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 16:08:09 -0700 (PDT)
Date: Thu, 6 Jul 2017 19:08:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC v2 0/5] surface heterogeneous memory performance information
Message-ID: <20170706230803.GE2919@redhat.com>
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Jul 06, 2017 at 03:52:28PM -0600, Ross Zwisler wrote:

[...]

> 
> ==== Next steps ====
> 
> There is still a lot of work to be done on this series, but the overall
> goal of this RFC is to gather feedback on which of the two options we
> should pursue, or whether some third option is preferred.  After that is
> done and we have a solid direction we can add support for ACPI hot add,
> test more complex configurations, etc.
> 
> So, for applications that need to differentiate between memory ranges based
> on their performance, what option would work best for you?  Is the local
> (initiator,target) performance provided by patch 5 enough, or do you
> require performance information for all possible (initiator,target)
> pairings?

Am i right in assuming that HBM or any faster memory will be relatively small
(1GB - 8GB maybe 16GB ?) and of fix amount (ie size will depend on the exact
CPU model you have) ?

If so i am wondering if we should not restrict NUMA placement policy for such
node to vma only. Forbid any policy that would prefer those node globally at
thread/process level. This would avoid wide thread policy to exhaust this
smaller pool of memory.

Drawback of doing so would be that existing applications would not benefit
from it. So workload where is acceptable to exhaust such memory wouldn't
benefit until their application are updated.


This is definitly not something impacting this patchset. I am just thinking
about this at large and i believe that NUMA might need to evolve slightly
to better handle memory hierarchy.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
