Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA31387
	for <linux-mm@kvack.org>; Thu, 29 Apr 1999 20:54:59 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14120.65367.60211.158632@dukat.scot.redhat.com>
Date: Fri, 30 Apr 1999 01:54:47 +0100 (BST)
Subject: Re: Hello
In-Reply-To: <v04020a01b34cd7f3c7c3@[198.115.92.60]>
References: <v04020a01b34cd7f3c7c3@[198.115.92.60]>
Sender: owner-linux-mm@kvack.org
To: "James E. King, III" <jking@ariessys.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 28 Apr 1999 11:28:07 -0400, "James E. King, III"
<jking@ariessys.com> said:

> 1. If I purchase a Quad Xeon 550 with 4 GB of memory, will Linux work
>    on it?  (I saw the whole thing about tweaking kernel parameters to
>    change from a 3:1 split to a 2:2 split)

It _will_ work, but by default will only use 1GB.  The most it can use
if you recompile the kernel is 2GB.

However, we have plans to support 64GB cleanly --- watch this space. :)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
