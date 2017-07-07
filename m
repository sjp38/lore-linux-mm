Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC606B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 01:30:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d62so23139133pfb.13
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 22:30:49 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 6si1692232plc.131.2017.07.06.22.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 22:30:48 -0700 (PDT)
Subject: Re: [RFC v2 0/5] surface heterogeneous memory performance information
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7cb3b9c4-9082-97e9-ebfd-542243bf652b@nvidia.com>
Date: Thu, 6 Jul 2017 22:30:46 -0700
MIME-Version: 1.0
In-Reply-To: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 07/06/2017 02:52 PM, Ross Zwisler wrote:
[...]
> 
> The naming collision between Jerome's "Heterogeneous Memory Management
> (HMM)" and this "Heterogeneous Memory (HMEM)" series is unfortunate, but I
> was trying to stick with the word "Heterogeneous" because of the naming of
> the ACPI 6.2 Heterogeneous Memory Attribute Table table.  Suggestions for
> better naming are welcome.
> 

Hi Ross,

Say, most of the places (file names, function and variable names, and even
print statements) where this patchset uses hmem or HMEM, it really seems to
mean, the Heterogeneous Memory Attribute Table. That's not *always* true, but
given that it's a pretty severe naming conflict, how about just changing:

hmem --> hmat
HMEM --> HMAT

...everywhere? Then you still have Heterogeneous Memory in the name, but
there is enough lexical distance (is that a thing? haha) between HMM and HMAT
to keep us all sane. :)

With or without the above suggestion, there are a few places (Kconfig, comments,
prints) where we can more easily make it clear that HMM != HMEM (or HMAT), 
so for those I can just comment on them separately in the individual patches.

thanks,
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
