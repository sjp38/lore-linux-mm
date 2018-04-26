Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDCF86B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:17:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n5so13386523pgq.3
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:17:08 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e1-v6si6770754pln.445.2018.04.26.11.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 11:17:07 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
 <CALvZod5NTauM6MHW7D=h0mTDNYFd-1QyWrOxnhiixCgtHP=Taw@mail.gmail.com>
 <alpine.DEB.2.21.1804261054540.1584@nanos.tec.linutronix.de>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e42df34f-3711-df42-55a9-61b147f17dce@intel.com>
Date: Thu, 26 Apr 2018 11:17:05 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1804261054540.1584@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Shakeel Butt <shakeelb@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, stable@kernel.org, linuxram@us.ibm.com, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On 04/26/2018 01:55 AM, Thomas Gleixner wrote:
>> Hi Dave, are you planning to send the next version of this patch or
>> going with this one?
> Right, some enlightment would be appreciated. I'm lost in the dozen
> different threads discussing this back and forth.

Shakeel, thanks for the reminder!

I'll send an updated set.  I got lost myself and thought this had been
picked up.

There were a few minor comments on the [v2] set that I've addressed.
I'll also check with Ram to make sure he's OK with this on ppc.  We had
some dueling patches at some point.
