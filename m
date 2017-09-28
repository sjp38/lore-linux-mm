Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9C0B6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 21:02:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x78so19850pff.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 18:02:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x3si206632pgp.597.2017.09.27.18.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 18:02:24 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
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
Date: Thu, 28 Sep 2017 09:02:20 +0800
In-Reply-To: <20170927141723.bixcum3fler7q4w5@dhcp22.suse.cz> (Michal Hocko's
	message of "Wed, 27 Sep 2017 16:17:23 +0200")
Message-ID: <87mv5f8wkj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Hi, Michal,

Michal Hocko <mhocko@kernel.org> writes:

> On Wed 27-09-17 23:10:08, Minchan Kim wrote:
>> On Wed, Sep 27, 2017 at 03:50:34PM +0200, Michal Hocko wrote:
>> > On Wed 27-09-17 22:41:17, Minchan Kim wrote:
>> > > On Wed, Sep 27, 2017 at 03:22:41PM +0200, Michal Hocko wrote:
>> > [...]
>> > > > simply cannot disable swap readahead when page-cluster is 0?
>> > > 
>> > > That's was what I want really but Huang want to use two readahead
>> > > algorithms in parallel so he wanted to keep two separated disable
>> > > knobs.
>> > 
>> > If it breaks existing and documented behavior then it is a clear
>> > regression and it should be fixed. I do not see why this should be
>> > disputable at all.
>> 
>> Indeed but Huang doesn't think so. He has thought it's not a regression.
>> Frankly speaking, I'm really bored of discussing with it.
>> https://marc.info/?l=linux-mm&m=150526413319763&w=2
>
> Then send a patch explaining why you consider this a regression with
> some numbers backing it and I will happily ack it.

I still think there may be a performance regression for some users
because of the change of the algorithm and the knobs, and the
performance regression can be resolved via setting the new knob.  But I
don't think there will be a functionality regression.  Do you agree?

Best Regards,
Huang, Ying

>> So I passed the decision to Andrew.
>> http://lkml.kernel.org/r/<20170913014019.GB29422@bbox>
>> 
>> The config option idea is compromise approach although I don't like it
>> and still believe it's simple clear *regression* so 0 page-cluster
>> should keep the swap readahead disabled.
>
> It is not a compromise. The regression is still there for many users
> potentially (just consider zram distribution kernel users...).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
