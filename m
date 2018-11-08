Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9D966B0640
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:11:56 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x5-v6so9120868pfn.22
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:11:56 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o1si4578572pgq.13.2018.11.08.12.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:11:55 -0800 (PST)
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
 <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
 <87bm6zaa04.fsf@oldenburg.str.redhat.com>
 <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
 <20181108200859.GD5481@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ed835eec-f775-c880-0434-bf3ef1e71709@intel.com>
Date: Thu, 8 Nov 2018 12:11:55 -0800
MIME-Version: 1.0
In-Reply-To: <20181108200859.GD5481@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Florian Weimer <fweimer@redhat.com>, linux-api@vger.kernel.org, linux-mm@kvack.org

On 11/8/18 12:08 PM, Ram Pai wrote:
>> Also, I'll be happy to review and ack the patch to do this, but I'd
>> expect the ppc guys (hi Ram!) to actually put it together.
> Hi Dave! :) So what is needed? Support a new flag PKEY_DISABLE_READ, and make it
> return error for all architectures?  
Florian proposed some semantics further up in the thread.  Basically if
someone asks for PKEY_DISABLE_READ, allow it to be accepted as long as
its compatible with the other flags.
