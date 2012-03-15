Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 60C406B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 02:15:50 -0400 (EDT)
Date: Wed, 14 Mar 2012 23:18:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] radix-tree: introduce bit-optimized iterator
Message-Id: <20120314231826.3938e451.akpm@linux-foundation.org>
In-Reply-To: <4F618347.8080400@openvz.org>
References: <20120210191611.5881.12646.stgit@zurg>
	<20120210192542.5881.91143.stgit@zurg>
	<20120314174356.40c35a07.akpm@linux-foundation.org>
	<4F618347.8080400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 15 Mar 2012 09:51:03 +0400 Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> > When a c programmer sees a variable called "i", he solidly expects it
> > to have type "int".  Please choose a better name for this guy!
> > Perferably something which helps the reader understand what the
> > variable's role is.
> 
> =) Ok, I can make it "int"

This should be an unsigned type - negative values are meaningless here.

And "i" is simply a poor identifier.  A good identifier is one which
communicates the variable's role.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
