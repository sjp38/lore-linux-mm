Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9956B0644
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:14:27 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f22so40372459qkm.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:14:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b197si851422qkc.16.2018.11.08.12.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:14:26 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
	<2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
	<87bm6zaa04.fsf@oldenburg.str.redhat.com>
	<6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
	<20181108200859.GD5481@ram.oc3035372033.ibm.com>
Date: Thu, 08 Nov 2018 21:14:19 +0100
In-Reply-To: <20181108200859.GD5481@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Thu, 8 Nov 2018 12:08:59 -0800")
Message-ID: <87ftwb72ec.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-api@vger.kernel.org, linux-mm@kvack.org

* Ram Pai:

> Hi Dave! :) So what is needed? Support a new flag PKEY_DISABLE_READ,
> and make it return error for all architectures?

PKEY_DISABLE_READ | PKEY_DISABLE_WRITE should be equivalent to
PKEY_DISABLE_ACCESS.  PKEY_DISABLE_READ without any other flag on x86
should return EINVAL (as for other invalid access rights specified for
pkey_alloc).

> Or are we enhancing the symantics of pkey_alloc() to allocate keys with
> just disable-read permissions.? And if so, will x86 be able to support
> that semantics?

I think x86 cannot do this, but POWER can, but it's currently not
possible to express this via pkey_alloc.  That could be fixed, too.

Thanks,
Florian
