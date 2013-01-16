Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 780D46B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:27:31 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 20:27:30 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4906EC90041
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:27:28 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G1RRtu43778062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:27:27 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G1RQuX010808
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:27:27 -0500
Message-ID: <50F601F7.3010000@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 17:27:19 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/17] mm/memory_hotplug: factor out zone+pgdat growth.
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com> <1358295894-24167-15-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-15-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On 01/15/2013 04:24 PM, Cody P Schafer wrote:
> Create a new function grow_pgdat_and_zone() which handles locking +
> growth of a zone & the pgdat which it is associated with.

Why is this being factored out?  Will it be reused somewhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
