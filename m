Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 310336B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 19:49:49 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id c58so3880620otd.17
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:49:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor2151579ota.324.2017.12.14.16.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 16:49:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214021019.13579-2-ross.zwisler@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com> <20171214021019.13579-2-ross.zwisler@linux.intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Fri, 15 Dec 2017 01:49:47 +0100
Message-ID: <CAJZ5v0iBoUpUK-RFq6Hn7OrJY+ZaVk7qnXpntwUjTo15KmTtZg@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] acpi: HMAT support in acpi_parse_entries_array()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu, Dec 14, 2017 at 3:10 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> The current implementation of acpi_parse_entries_array() assumes that each
> subtable has a standard ACPI subtable entry of type struct
> acpi_subtable_header.  This standard subtable header has a one byte length
> followed by a one byte type.
>
> The HMAT subtables have to allow for a longer length so they have subtable
> headers of type struct acpi_hmat_structure which has a 2 byte type and a 4
> byte length.
>
> Enhance the subtable parsing in acpi_parse_entries_array() so that it can
> handle these new HMAT subtables.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

This one is fine by me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
