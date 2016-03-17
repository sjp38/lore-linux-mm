Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0244F6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:05:31 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 124so114583654pfg.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 03:05:30 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id un9si11568901pac.14.2016.03.17.03.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 03:05:30 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: ARC !THP broken in linux-next (was Re: [PATCH V2]
 mm/thp/migration: switch from flush_tlb_range to flush_pmd_tlb_range)
Date: Thu, 17 Mar 2016 10:05:27 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F4E90333@us01wembx1.internal.synopsys.com>
References: <1455118510-15031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <56EA7A78.6020308@synopsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>

On Thursday 17 March 2016 03:06 PM, Vineet Gupta wrote:=0A=
> @Andrew could you please add the patch below to mm tree !=0A=
=0A=
Never mind - I pushed it to my tree as this fix has no real dependency on o=
riginal=0A=
patch and seems to be the right things with or w/o it.=0A=
=0A=
Thx,=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
