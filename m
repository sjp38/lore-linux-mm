Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3AA8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:03:14 -0400 (EDT)
Date: Wed, 23 Mar 2011 15:02:35 +0100
From: David Sterba <dave@jikos.cz>
Subject: Re: ext4 deep stack with mark_page_dirty reclaim
Message-ID: <20110323140235.GF17108@twin.jikos.cz>
Reply-To: dave@jikos.cz
References: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
 <20110314204627.GB8120@thunk.org>
 <FE7209AC-C66C-4482-945E-58CF5AF8FEE7@dilger.ca>
 <20110315152222.GW17108@twin.jikos.cz>
 <1300206353-sup-9759@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1300206353-sup-9759@think>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: dave <dave@jikos.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, adilger <adilger@dilger.ca>

On Tue, Mar 15, 2011 at 12:26:43PM -0400, Chris Mason wrote:
> Also, the ftrace stack usage tracer gives more verbose output that
> includes the size of each function.

Yet another one on the list is the -fstack-size option in new gcc 4.6 [*].
It creates a file with .su extension containing lines in format
file:line:char:function_name	stack_size	linkage_type

eg.

a.c:168:5:main     224     static


dave

* http://gcc.gnu.org/gcc-4.6/changes.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
