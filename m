Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 23DAA6B0006
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:51 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 12:52:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8B315C90058
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:46 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LHqktN341218
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:46 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LHqkns030222
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:46 -0500
Subject: [PATCH 0/5] fix illegal use of __pa() in KVM code
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 09:52:44 -0800
Message-Id: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>

This series fixes a hard-to-debug early boot hang on 32-bit
NUMA systems.  It adds coverage to the debugging code,
adds some helpers, and eventually fixes the original bug I
was hitting.

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
