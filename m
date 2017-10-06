Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6C556B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 08:29:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k56so9004746qtc.1
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 05:29:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor928278qkl.49.2017.10.06.05.29.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 05:29:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002144903.d58ed6887adfd9dc4cdfd697@linux-foundation.org>
References: <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
 <20170927050401.GA715@bbox> <20170927074835.37m4dclmew5ecli2@dhcp22.suse.cz>
 <20170927080432.GA1160@bbox> <20170927083512.dydqlqezh5polggb@dhcp22.suse.cz>
 <20170927131511.GA338@bgram> <20170927132241.tshup6kcwe5pcxek@dhcp22.suse.cz>
 <20170927134117.GB338@bgram> <20170927135034.yatxlhvunawzmcar@dhcp22.suse.cz>
 <20170927141008.GA1278@bgram> <20170927141723.bixcum3fler7q4w5@dhcp22.suse.cz>
 <87mv5f8wkj.fsf@yhuang-dev.intel.com> <e7531802-c4bc-9a5b-1a9c-d7909f2d1107@intel.com>
 <20171002144903.d58ed6887adfd9dc4cdfd697@linux-foundation.org>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Fri, 6 Oct 2017 20:28:59 +0800
Message-ID: <CAC=cRTMMHX1SqPygkh+4scmhQhv3=kZMJAFf=EhZZU9S2006JA@mail.gmail.com>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>

On Tue, Oct 3, 2017 at 5:49 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 2 Oct 2017 08:45:40 -0700 Dave Hansen <dave.hansen@intel.com> wrote:
>
>> On 09/27/2017 06:02 PM, Huang, Ying wrote:
>> > I still think there may be a performance regression for some users
>> > because of the change of the algorithm and the knobs, and the
>> > performance regression can be resolved via setting the new knob.  But I
>> > don't think there will be a functionality regression.  Do you agree?
>>
>> A performance regression is a regression.  I don't understand why we are
>> splitting hairs as to what kind of regression it is.
>>
>
> Yes.
>
> Ying, please find us a way of avoiding any disruption to existing
> system setups.  One which doesn't require that the operator perform a
> configuration change to restore prior behaviour/performance.

Sorry for late.  I am in holiday recently.

OK.  For me, I think the most clean way is to use page_cluster to
control both the virtual and physical swap readahead.  If you are OK
with that, I will prepare the patch.

> And please let's get this done well in advance of the 4.14 release.

Sure.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
