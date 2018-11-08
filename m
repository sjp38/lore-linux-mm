Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF1796B05EB
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 07:05:21 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 67so36624139qkj.18
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 04:05:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l2si2913910qvo.45.2018.11.08.04.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 04:05:21 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: pkeys: Reserve PKEY_DISABLE_READ
Date: Thu, 08 Nov 2018 13:05:09 +0100
Message-ID: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, linuxram@us.ibm.com

Would it be possible to reserve a bit for PKEY_DISABLE_READ?

I think the POWER implementation can disable read access at the hardware
level, but not write access, and that cannot be expressed with the
current PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE bits.

My upcoming POWER implementation of pkey_set and pkey_get in glibc would
benefit from this.

Thanks,
Florian
