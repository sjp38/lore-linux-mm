Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AFF1A6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 03:22:20 -0400 (EDT)
Received: by wyi11 with SMTP id 11so2932191wyi.14
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 00:22:17 -0700 (PDT)
Subject: Re: Subject: [PATCH V7 4/4] mm: frontswap: config and doc files
From: Sasha Levin <levinsasha928@gmail.com>
In-Reply-To: <20110823145855.GA23251@ca-server1.us.oracle.com>
References: <20110823145855.GA23251@ca-server1.us.oracle.com>
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 26 Aug 2011 10:22:10 +0300
Message-ID: <1314343330.3647.32.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

Just wanted to note that I found the documentation very useful, it made
it very easy to understand whats going on.

On Tue, 2011-08-23 at 07:58 -0700, Dan Magenheimer wrote:
> +In the virtual case, the whole point of virtualization is to statistically
> +multiplex physical resources acrosst the varying demands of multiple
				across
> +virtual machines.  This is really hard to do with RAM and efforts to do

-- 

Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
