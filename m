Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8BED6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:44:26 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id x37so235040326ota.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 12:44:26 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id x79si4965835oia.292.2017.03.13.12.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 12:44:25 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id 126so82957982oig.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 12:44:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170313185710.GA3422@osiris>
References: <20170309130616.51286-1-heiko.carstens@de.ibm.com>
 <3207330.x0D3JT6f2l@aspire.rjw.lan> <CAPcyv4g7_E1JTCGq1_gC7W2JtS2JXmWGPuiHW5CMNpjWs2DXpg@mail.gmail.com>
 <2552966.WcQWnf8t6b@aspire.rjw.lan> <20170313185710.GA3422@osiris>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 Mar 2017 12:44:25 -0700
Message-ID: <CAPcyv4i1phF5rZL--g6ojguHScKetNA3gfsZRpHhVw3VbgqmFg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: add private lock to serialize memory hotplug operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Mon, Mar 13, 2017 at 11:57 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> On Thu, Mar 09, 2017 at 11:34:44PM +0100, Rafael J. Wysocki wrote:
>> > The memory described by devm_memremap_pages() is never "onlined" to
>> > the core mm. We're only using arch_add_memory() to get a linear
>> > mapping and page structures. The rest of memory hotplug is skipped,
>> > and this ZONE_DEVICE memory is otherwise hidden from the core mm.
>>
>> OK, that should be fine then.
>
> So, does that mean that the patch is ok as it is? If so, it would be good
> to get an Ack from both, you and Dan, please.

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
