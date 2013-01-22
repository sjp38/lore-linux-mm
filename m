Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 724C46B000C
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:25:15 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 16:25:14 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C60496E8043
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:25:09 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0MLP9wO241168
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:25:10 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0MLOYoj018378
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 14:24:34 -0700
Subject: [PATCH 0/5] [v3] fix illegal use of __pa() in KVM code
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Tue, 22 Jan 2013 13:24:28 -0800
Message-Id: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>

This series fixes a hard-to-debug early boot hang on 32-bit
NUMA systems.  It adds coverage to the debugging code,
adds some helpers, and eventually fixes the original bug I
was hitting.

[v3]
 * Remove unnecessary initializations in slow_virt_to_phys(),
   and convert 'level' to use the new enum pg_level.
 * Add some text to slow_virt_to_phys() to make it clear
   that we are not using it in any remotely fast paths.
[v2]
 * Moved DEBUG_VIRTUAL patch earlier in the series (it has no
   dependencies on anything else and stands on its own.
 * Created page_level_*() helpers to replace a nasty switch()
   at hpa's suggestion
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
