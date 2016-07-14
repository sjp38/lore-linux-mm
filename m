Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA076B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 03:19:18 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so47206179lfg.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 00:19:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a2si1007132wjk.265.2016.07.14.00.19.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 00:19:16 -0700 (PDT)
Date: Thu, 14 Jul 2016 09:19:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:since-4.6 827/827]
 arch/s390/include/asm/jump_label.h:17:32: error: expected ':' before
 '__stringify'
Message-ID: <20160714071914.GA27689@dhcp22.suse.cz>
References: <201607140156.2OxakZPq%fengguang.wu@intel.com>
 <57867DD0.9080801@akamai.com>
 <20160713110542.b58b2bcc7ca484a56cb903f3@linux-foundation.org>
 <5786856B.6030600@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5786856B.6030600@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org

On Wed 13-07-16 14:16:11, Jason Baron wrote:
> On 07/13/2016 02:05 PM, Andrew Morton wrote:
> > On Wed, 13 Jul 2016 13:43:44 -0400 Jason Baron <jbaron@akamai.com> wrote:
> > 
> >> This is likely due to the fact that the s390 bits
> >> bits were not pulled into -mm here:
> >>
> >> http://lkml.iu.edu/hypermail/linux/kernel/1607.0/03114.html
> >>
> >> However, I do see them in linux-next, I think from
> >> the s390 tree. So perhaps, that patch can be pulled
> >> in here as well?
> > 
> > Yup, I have
> > jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
> > staged after linux-next and it has that dependency on linux-next.
> > 
> 
> ok, you have the dependency correct, thanks.
> 
> That dependency though is not being honored in the referenced
> mm tree branch 'since-4.6', since the relevant s390 patch
> is not present. So, if we want to fix it here, we need
> that patch...

My fault. I haven't noticed this patch. I usually apply everything that
is in appropriate sections of series file and then fix up compilation
issues. I didn't do my allarch build test the last time due to lack of
time so I haven't noticed this. Sorry about that!

That being said, I have cherry-picked the s390 part.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
