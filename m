Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEFE66B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 11:41:11 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id w15so9778407plp.14
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 08:41:11 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c1si13342409pld.12.2017.12.20.08.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 08:41:10 -0800 (PST)
Date: Wed, 20 Dec 2017 09:41:07 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171220164107.GA29103@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214130032.GK16951@dhcp22.suse.cz>
 <20171218203547.GA2366@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218203547.GA2366@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org

On Mon, Dec 18, 2017 at 01:35:47PM -0700, Ross Zwisler wrote:
> On Thu, Dec 14, 2017 at 02:00:32PM +0100, Michal Hocko wrote:
<>
> > What is the testing procedure? How can I setup qemu to simlate such HW?
> 
> Well, the QEMU table simulation is gross, so I'd rather not get everyone
> testing with that.  Injecting custom HMAT and SRAT tables via initrd/initramfs
> is a much better way:
> 
> https://www.kernel.org/doc/Documentation/acpi/initrd_table_override.txt
> 
> Dan recently posted a patch that lets this happen for the HMAT:
> 
> https://lists.01.org/pipermail/linux-nvdimm/2017-December/013545.html
> 
> I'm working right now on getting an easier way to generate HMAT tables - I'll
> let you know when I have something working.

I've posted details on how to set up test configurations using injected HMAT
and SRAT tables here:

https://github.com/rzwisler/hmat_examples

So far I've got two different sample configs, and we can add more as they are
useful.  Having the sample configs in github is also nice because if someone
finds a config that causes a kernel issue it can be reported then added to
this list of example configs for future testing.

Please let me know if you have trouble getting this working.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
