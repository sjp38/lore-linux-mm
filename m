Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1286B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 11:45:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so12847560pfj.3
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 08:45:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e1si7654769pgo.535.2017.10.02.08.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 08:45:42 -0700 (PDT)
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
References: <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
 <20170927050401.GA715@bbox> <20170927074835.37m4dclmew5ecli2@dhcp22.suse.cz>
 <20170927080432.GA1160@bbox> <20170927083512.dydqlqezh5polggb@dhcp22.suse.cz>
 <20170927131511.GA338@bgram> <20170927132241.tshup6kcwe5pcxek@dhcp22.suse.cz>
 <20170927134117.GB338@bgram> <20170927135034.yatxlhvunawzmcar@dhcp22.suse.cz>
 <20170927141008.GA1278@bgram>
 <20170927141723.bixcum3fler7q4w5@dhcp22.suse.cz>
 <87mv5f8wkj.fsf@yhuang-dev.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e7531802-c4bc-9a5b-1a9c-d7909f2d1107@intel.com>
Date: Mon, 2 Oct 2017 08:45:40 -0700
MIME-Version: 1.0
In-Reply-To: <87mv5f8wkj.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>

On 09/27/2017 06:02 PM, Huang, Ying wrote:
> I still think there may be a performance regression for some users
> because of the change of the algorithm and the knobs, and the
> performance regression can be resolved via setting the new knob.  But I
> don't think there will be a functionality regression.  Do you agree?

A performance regression is a regression.  I don't understand why we are
splitting hairs as to what kind of regression it is.

Are you only willing to fix it if it's a functional regression?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
