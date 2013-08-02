Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3E0A46B0034
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 13:10:49 -0400 (EDT)
Message-ID: <51FBE807.6040907@intel.com>
Date: Fri, 02 Aug 2013 10:10:31 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH resend] drop_caches: add some documentation and info message
References: <1375459442.8422.1@driftwood>
In-Reply-To: <1375459442.8422.1@driftwood>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Landley <rob@landley.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, dave@linux.vnet.ibm.com

On 08/02/2013 09:04 AM, Rob Landley wrote:
> I'd be surprised if anybody who does this sees the printk and thinks
> "hey, I'll dig into the VM's balancing logic and come up to speed on the
> tradeoffs sufficient to contribute to kernel development" because of
> something in dmesg. Anybody actually annoyed by it will chop out the
> printk (you barely need to know C to do that), the rest won't notice.

All that I expect is that this will get _some_ of these folks in to a
feedback loop with us.  They'll see this in dmesg and either go asking
questions within their respective companies, file bugs with distros, or
post to LKML.

Some of them are going to say things like "My Database Vendor told me
this optimizes my server!", or that the documentation told them to do it
so they don't run out of memory.  Some of them might even be running in
to _legitimate_ VM or filesystem bugs that they're working around with this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
