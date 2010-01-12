Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 059146B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 03:18:37 -0500 (EST)
Date: Tue, 12 Jan 2010 00:16:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended
 numbering support
Message-Id: <20100112001647.3b992391.akpm@linux-foundation.org>
In-Reply-To: <20100112.170503.112616928.d.hatayama@jp.fujitsu.com>
References: <20100107162928.1d6eba76.akpm@linux-foundation.org>
	<20100112.121232.189721840.d.hatayama@jp.fujitsu.com>
	<20100111192418.5cd8a554.akpm@linux-foundation.org>
	<20100112.170503.112616928.d.hatayama@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 17:05:03 +0900 (JST) Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com> wrote:

> My concern is possibility of dump_seek()'s very short and general
> naming wasting public name space and colliding other global names.  My
> idea is, for example, to rename it coredump_dump_seek().

OK.  Yes, that would be a bit nicer.  I'm sure we have lots more
inappropriately named globals than that though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
