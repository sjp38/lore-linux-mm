Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2551B6B0347
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 07:31:31 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id a3so1178417itg.7
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 04:31:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 67si666544ioc.147.2018.01.03.04.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 04:31:30 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: [PATCH] mm, x86: pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Message-ID: <360ef254-48bc-aee6-70f9-858f773b8693@redhat.com>
Date: Wed, 3 Jan 2018 13:31:25 +0100
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------63FE4E7AB35B75B5A148D63E"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, x86@kernel.org, Dave Hansen <dave.hansen@intel.com>, Ram Pai <linuxram@us.ibm.com>

This is a multi-part message in MIME format.
--------------63FE4E7AB35B75B5A148D63E
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

This patch is based on the previous discussion (pkeys: Support setting 
access rights for signal handlers):

   https://marc.info/?t=151285426000001

It aligns the signal semantics of the x86 implementation with the 
upcoming POWER implementation, and defines a new flag, so that 
applications can detect which semantics the kernel uses.

A change in this area is needed to make memory protection keys usable 
for protecting the GOT in the dynamic linker.

(Feel free to replace the trigraphs in the commit message before 
committing, or to remove the program altogether.)

Thanks,
Florian

--------------63FE4E7AB35B75B5A148D63E
Content-Type: text/x-patch;
 name="pkeys-signalinherit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pkeys-signalinherit.patch"


--------------63FE4E7AB35B75B5A148D63E--
