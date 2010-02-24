Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5CF746B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:34:39 -0500 (EST)
Date: Wed, 24 Feb 2010 15:34:42 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
Message-ID: <20100224143442.GF3687@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: lsf10-pc@lists.linuxfoundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  Hi,

  one more suggestion for discussion:
Currently, the amount of dirtiable memory is fixed - either to a percentage
of ram (dirty_limit) or to a fix number of megabytes. The problem with this
is that if you have application doing random writes on a file (like some
simple databases do), you'll get a big performance improvement if you
increase the amount of dirtiable memory (because you safe quite some
rewrites and also get larger chunks of sequential IO) (*)
On the other hand for sequential IO increasing dirtiable memory (beyond
certain level) does not really help - you end up doing the same IO.  So for
a machine is doing sequential IO, having 10% of memory dirtiable is just
fine (and you probably don't want much more because the memory is better
used for something else), when a machine does random rewrites, going to 40%
might be well worth it. So I'd like to discuss how we could measure that
increasing amount of dirtiable memory helps so that we could implement
dynamic sizing of it.

(*) We ended up increasing dirty_limit in SLES 11 to 40% as it used to be
with old kernels because customers running e.g. LDAP (using BerkelyDB
heavily) were complaining about performance problems.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
