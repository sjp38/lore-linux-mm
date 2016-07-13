Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A79C96B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:16:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r65so114751609qkd.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:16:15 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com (prod-mail-xrelay05.akamai.com. [23.79.238.179])
        by mx.google.com with ESMTP id f18si2989243qkh.171.2016.07.13.11.16.13
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 11:16:14 -0700 (PDT)
Subject: Re: [memcg:since-4.6 827/827]
 arch/s390/include/asm/jump_label.h:17:32: error: expected ':' before
 '__stringify'
References: <201607140156.2OxakZPq%fengguang.wu@intel.com>
 <57867DD0.9080801@akamai.com>
 <20160713110542.b58b2bcc7ca484a56cb903f3@linux-foundation.org>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <5786856B.6030600@akamai.com>
Date: Wed, 13 Jul 2016 14:16:11 -0400
MIME-Version: 1.0
In-Reply-To: <20160713110542.b58b2bcc7ca484a56cb903f3@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 07/13/2016 02:05 PM, Andrew Morton wrote:
> On Wed, 13 Jul 2016 13:43:44 -0400 Jason Baron <jbaron@akamai.com> wrote:
> 
>> This is likely due to the fact that the s390 bits
>> bits were not pulled into -mm here:
>>
>> http://lkml.iu.edu/hypermail/linux/kernel/1607.0/03114.html
>>
>> However, I do see them in linux-next, I think from
>> the s390 tree. So perhaps, that patch can be pulled
>> in here as well?
> 
> Yup, I have
> jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
> staged after linux-next and it has that dependency on linux-next.
> 

ok, you have the dependency correct, thanks.

That dependency though is not being honored in the referenced
mm tree branch 'since-4.6', since the relevant s390 patch
is not present. So, if we want to fix it here, we need
that patch...

Thanks,

-Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
