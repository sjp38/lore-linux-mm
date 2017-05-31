Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA2D46B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:25:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r6so9912892pgf.15
        for <linux-mm@kvack.org>; Wed, 31 May 2017 05:25:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m8si15942476pgn.69.2017.05.31.05.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 05:25:57 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4VCPQ9N072714
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:25:56 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2asun6e1uw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:25:56 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 31 May 2017 13:25:51 +0100
Date: Wed, 31 May 2017 15:25:43 +0300
In-Reply-To: <20170531120533.GK27783@dhcp22.suse.cz>
References: <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz> <20170524075043.GB3063@rapoport-lnx> <c59a0893-d370-130b-5c33-d567a4621903@suse.cz> <20170524103947.GC3063@rapoport-lnx> <20170524111800.GD14733@dhcp22.suse.cz> <20170524142735.GF3063@rapoport-lnx> <20170530074408.GA7969@dhcp22.suse.cz> <20170530101921.GA25738@rapoport-lnx> <20170530103930.GB7969@dhcp22.suse.cz> <20170531090844.GA25375@rapoport-lnx> <20170531120533.GK27783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <D593CAD3-C8AB-479F-970C-AF67F00CEF3A@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>



On May 31, 2017 3:05:56 PM GMT+03:00, Michal Hocko <mhocko@kernel=2Eorg> w=
rote:
>On Wed 31-05-17 12:08:45, Mike Rapoport wrote:
>> On Tue, May 30, 2017 at 12:39:30PM +0200, Michal Hocko wrote:
>[=2E=2E=2E]
>> > Also do you expect somebody else would use new madvise? What would
>be the
>> > usecase?
>>=20
>> I can think of an application that wants to keep 4K pages to save
>physical
>> memory for certain phase, e=2Eg=2E until these pages are populated with
>very
>> few data=2E After the memory usage increases, the application may wish
>to
>> stop preventing khugepged from merging these pages, but it does not
>have
>> strong inclination to force use of huge pages=2E
>
>Well, is actually anybody going to do that?

Well, I don't=E2=80=8B know, it's pretty much future telling :)
For sure, without the new madvise nobody will be even able to do that=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
