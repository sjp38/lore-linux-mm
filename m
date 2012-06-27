Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7FD336B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 02:10:35 -0400 (EDT)
Received: by dakp5 with SMTP id p5so1082002dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 23:10:34 -0700 (PDT)
Date: Tue, 26 Jun 2012 23:10:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 1/12] memory-hotplug : rename remove_memory to
 offline_memory
In-Reply-To: <4FEA9D5C.1080508@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206262309301.32567@chino.kir.corp.google.com>
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9D5C.1080508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On Wed, 27 Jun 2012, Yasuaki Ishimatsu wrote:

> remove_memory() does not remove memory but just offlines memory. The patch
> changes name of it to offline_memory().
> 

The kernel is never going to physically remove the memory itself, so I 
don't see the big problem with calling it remove_memory().  If you're 
going to change it to offline_memory(), which is just as good but not 
better, then I'd suggest changing add_memory() to online_memory() for 
completeness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
