Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF84C6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:05:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id q2so93112055pap.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:05:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bp2si5527539pab.151.2016.07.13.11.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 11:05:43 -0700 (PDT)
Date: Wed, 13 Jul 2016 11:05:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg:since-4.6 827/827]
 arch/s390/include/asm/jump_label.h:17:32: error: expected ':' before
 '__stringify'
Message-Id: <20160713110542.b58b2bcc7ca484a56cb903f3@linux-foundation.org>
In-Reply-To: <57867DD0.9080801@akamai.com>
References: <201607140156.2OxakZPq%fengguang.wu@intel.com>
	<57867DD0.9080801@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Wed, 13 Jul 2016 13:43:44 -0400 Jason Baron <jbaron@akamai.com> wrote:

> This is likely due to the fact that the s390 bits
> bits were not pulled into -mm here:
> 
> http://lkml.iu.edu/hypermail/linux/kernel/1607.0/03114.html
> 
> However, I do see them in linux-next, I think from
> the s390 tree. So perhaps, that patch can be pulled
> in here as well?

Yup, I have
jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
staged after linux-next and it has that dependency on linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
