Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C92F6B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 07:52:12 -0400 (EDT)
Received: by igfk2 with SMTP id k2so1186888igf.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 04:52:12 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id nv7si2225845igb.3.2015.10.09.04.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 04:52:12 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH v2 00/12] THP support for ARC
Date: Fri, 9 Oct 2015 11:52:04 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781BE6F@IN01WEMBXB.internal.synopsys.com>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
 <560CCC73.9080705@synopsys.com> <561789E6.9090800@synopsys.com>
 <20151009101046.GA8081@node> <5617A527.9030902@synopsys.com>
 <20151009114336.GB8081@node>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Friday 09 October 2015 05:13 PM, Kirill A. Shutemov wrote:=0A=
> Side question: I was surprised by your patchset. I didn't think about ARC=
=0A=
> as an architecture which would benefit from THP. How big ARC systems=0A=
> nowadays? How big benefit did you measured there from THP? =0A=
=0A=
Hardware support for THP on ARC is relatively recent - as part of newly ann=
ounced=0A=
HS38x cores. So we don't have silicon yet to measure the performance benefi=
ts. I'm=0A=
currently testing this on our nsim simulator but we are slated to get silic=
on with=0A=
this pretty soon.=0A=
=0A=
If you were surprised by this you will likely be more with my highmem / PAE=
40=0A=
support patches which I will send out early next week ;-)=0A=
=0A=
Customers these days want more future safety, if nothing else and these fea=
tures=0A=
were added per more of them wanting these in their designs.=0A=
=0A=
Thx for taking time to go thru this stuff !=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
