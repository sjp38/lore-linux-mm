Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85D176B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 04:19:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l2so2491812wml.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 01:19:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h194si2073903wmd.115.2017.01.06.01.19.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 01:19:42 -0800 (PST)
Date: Fri, 6 Jan 2017 10:19:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
Message-ID: <20170106091934.GF5556@dhcp22.suse.cz>
References: <d234fb8b-965f-d966-46fe-965478fdf7cb@linux.intel.com>
 <8612e7db-97c5-f757-0aae-24c3acedbc29@oracle.com>
 <2c0502d0-20ef-44ac-db5b-7f651a70b978@linux.intel.com>
 <ba9c4de2-cec1-1c88-82c9-24a524eb7948@oracle.com>
 <db31d324-a1ae-7450-0e54-ad98da205773@linux.intel.com>
 <5a0270ea-b29a-0751-a27f-2412a8588561@oracle.com>
 <7532a1d6-6562-b10b-dacd-931cb2a9e536@linux.intel.com>
 <92d55a69-b400-8461-53a1-d505de089700@oracle.com>
 <75c31c99-cff7-72dc-f593-012fe5acd405@linux.intel.com>
 <7fbc4ca1-22ef-8ef5-5c1b-dd075852e512@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fbc4ca1-22ef-8ef5-5c1b-dd075852e512@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rob Gardner <rob.gardner@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On Thu 05-01-17 13:30:10, Khalid Aziz wrote:
[...]
> It is very tempting to restrict tags to PAGE_SIZE granularity since it makes
> code noticeably simpler and that is indeed going to be the majority of
> cases. Sooner or later somebody would want to use multiple tags per page
> though.

I didn't get to read the patch throughly yet but I am really confused by
this statement. The api is mprotect based which makes it ineherently
PAGE_SIZE granular. How do you want to achieve cache line granularity
with this API?

And I would really vote for simplicity first... Subpage granularity
sounds way too tricky...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
