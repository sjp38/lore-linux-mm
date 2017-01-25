Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3570E6B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:13:33 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so287870125pge.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:13:33 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id 15si24675171pgg.226.2017.01.25.14.13.32
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 14:13:32 -0800 (PST)
Date: Wed, 25 Jan 2017 17:13:28 -0500 (EST)
Message-Id: <20170125.171328.1978684823149751445.davem@davemloft.net>
Subject: Re: [PATCH v5 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
From: David Miller <davem@davemloft.net>
In-Reply-To: <154bc417-6333-f9ac-653b-9ed280f08450@oracle.com>
References: <cover.1485362562.git.khalid.aziz@oracle.com>
	<0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
	<154bc417-6333-f9ac-653b-9ed280f08450@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob.gardner@oracle.com
Cc: khalid.aziz@oracle.com, corbet@lwn.net, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, keescook@chromium.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Rob Gardner <rob.gardner@oracle.com>
Date: Wed, 25 Jan 2017 15:00:42 -0700

> Same comment here, and the various other places that employ this same
> code construct.

Please do not quote an entire huge patch just to comment on a small
part of it.

Quote only the minimum necessary context in order to provide your feedback.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
