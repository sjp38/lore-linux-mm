Date: Sun, 8 Jun 2008 11:59:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 05/21] hugetlb: new sysfs interface
Message-Id: <20080608115941.746732a5.akpm@linux-foundation.org>
In-Reply-To: <20080604113111.647714612@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113111.647714612@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 21:29:44 +1000 npiggin@suse.de wrote:

> Provide new hugepages user APIs that are more suited to multiple hstates in
> sysfs. There is a new directory, /sys/kernel/hugepages. Underneath that
> directory there will be a directory per-supported hugepage size, e.g.:
> 
> /sys/kernel/hugepages/hugepages-64kB
> /sys/kernel/hugepages/hugepages-16384kB
> /sys/kernel/hugepages/hugepages-16777216kB

Maybe /sys/mm or /sys/vm would be a more appropriate place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
