Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C08C68E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:36:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so18997787pfi.21
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:36:38 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id d189si17530719pfa.70.2018.12.19.09.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 09:36:37 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: Re: [PATCH 1/2] ARC: show_regs: avoid page allocator
Date: Wed, 19 Dec 2018 17:36:35 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075014642226B@US01WEMBX2.internal.synopsys.com>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
 <1545239047.14089.13.camel@synopsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/19/18 9:04 AM, Eugeniy Paltsev wrote:=0A=
> Just curious: isn't that enough to use GFP_NOWAIT instead=0A=
> of GFP_KERNEL when we allocate page in show_regs()?=0A=
>=0A=
> As I can see x86 use print_vma_addr() in their show_signal_msg()=0A=
> function which allocate page with __get_free_page(GFP_NOWAIT);=0A=
=0A=
I'm not sure if lockdep will be happy with it still.=0A=
=0A=
At any rate, as explained in changelog, this still has merit, since the buf=
fer is=0A=
only needed for nested d_path calls, which are better served with a smaller=
=0A=
on-stack buffer. For cases such as kernel crash, we want lesser code/traces=
 in=0A=
fault path to sift thru !=0A=
=0A=
-Vineet=0A=
