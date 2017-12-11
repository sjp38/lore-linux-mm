Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7796D6B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 11:13:16 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m17so13288486pgu.19
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 08:13:16 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o3si10092665pld.358.2017.12.11.08.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 08:13:15 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
 <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
Date: Mon, 11 Dec 2017 08:13:12 -0800
MIME-Version: 1.0
In-Reply-To: <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, Ram Pai <linuxram@us.ibm.com>

On 12/09/2017 10:42 PM, Florian Weimer wrote:
>> My only nit with this is whether it is the *right* interface.  The 
>> signal vs. XSAVE state thing is pretty x86 specific and I doubt
>> that this will be the last feature that we encounter that needs
>> special signal behavior.
> 
> The interface is not specific to XSAVE.  To generic code, only the
> two signal mask manipulation functions are exposed.  And I expect
> that we're going to need that for other (non-x86) implementations
> because they will have the same issue because the signal handler
> behavior will be identical.

Let's check with the other implementation...

Ram, this is a question about the signal handler behavior on POWER.  I
thought you ended up having different behavior in signal handlers than x86.

In any case, I think the question still stands: Do we want this to be
pkeys-only, or build it so that it can be used for MPX and any future
XSAVE features that need non-init values when entering a signal handler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
