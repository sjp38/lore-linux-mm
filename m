Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA12417
	for <linux-mm@kvack.org>; Tue, 9 Feb 1999 11:33:29 -0500
Date: Tue, 9 Feb 1999 08:32:52 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: swapcache bug?
In-Reply-To: <m1k8xs120f.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990209082927.32602B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, masp0008@stud.uni-sb.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On 9 Feb 1999, Eric W. Biederman wrote:
> 
> ???  With the latter OMAGIC format everthing is page aligned already.

Yes.

However, it's a question of pride too. I don't want to break "normal" user
land applications (as opposed to things like "ifconfig" that are really
very very special), unless I really have to.

As such, I want to support even the old 1kB-aligned ZMAGIC binaries for as
long as it's not a liability, and quite frankly the issue of whether you
make the page cache "offset" be a sector or a page offset is purely a
thing of taste, not a liability.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
