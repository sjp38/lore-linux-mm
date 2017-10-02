Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B84F6B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:49:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g10so3264854wrg.2
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:49:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b11si8338096wmh.265.2017.10.02.14.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:49:08 -0700 (PDT)
Date: Mon, 2 Oct 2017 14:49:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-Id: <20171002144903.d58ed6887adfd9dc4cdfd697@linux-foundation.org>
In-Reply-To: <e7531802-c4bc-9a5b-1a9c-d7909f2d1107@intel.com>
References: <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
	<20170927050401.GA715@bbox>
	<20170927074835.37m4dclmew5ecli2@dhcp22.suse.cz>
	<20170927080432.GA1160@bbox>
	<20170927083512.dydqlqezh5polggb@dhcp22.suse.cz>
	<20170927131511.GA338@bgram>
	<20170927132241.tshup6kcwe5pcxek@dhcp22.suse.cz>
	<20170927134117.GB338@bgram>
	<20170927135034.yatxlhvunawzmcar@dhcp22.suse.cz>
	<20170927141008.GA1278@bgram>
	<20170927141723.bixcum3fler7q4w5@dhcp22.suse.cz>
	<87mv5f8wkj.fsf@yhuang-dev.intel.com>
	<e7531802-c4bc-9a5b-1a9c-d7909f2d1107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>

On Mon, 2 Oct 2017 08:45:40 -0700 Dave Hansen <dave.hansen@intel.com> wrote:

> On 09/27/2017 06:02 PM, Huang, Ying wrote:
> > I still think there may be a performance regression for some users
> > because of the change of the algorithm and the knobs, and the
> > performance regression can be resolved via setting the new knob.  But I
> > don't think there will be a functionality regression.  Do you agree?
> 
> A performance regression is a regression.  I don't understand why we are
> splitting hairs as to what kind of regression it is.
> 

Yes.

Ying, please find us a way of avoiding any disruption to existing
system setups.  One which doesn't require that the operator perform a
configuration change to restore prior behaviour/performance.  And
please let's get this done well in advance of the 4.14 release.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
