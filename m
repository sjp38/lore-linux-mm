Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BCA52900138
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 19:27:15 -0400 (EDT)
Date: Wed, 7 Sep 2011 16:27:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V8 3/4] mm: frontswap: add swap hooks and extend
 try_to_unuse
Message-Id: <20110907162703.7f8116b9.akpm@linux-foundation.org>
In-Reply-To: <20110829164929.GA27216@ca-server1.us.oracle.com>
References: <20110829164929.GA27216@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Mon, 29 Aug 2011 09:49:29 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> -static int try_to_unuse(unsigned int type)
> +int try_to_unuse(unsigned int type, bool frontswap,

Are patches 2 and 3 in the wrong order?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
