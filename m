Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA08011
	for <linux-mm@kvack.org>; Mon, 3 Aug 1998 17:31:24 -0400
Date: Mon, 3 Aug 1998 19:16:14 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: S3trio framebuffer on Intel?
In-Reply-To: <Pine.LNX.3.96.980803072540.18271D-100000@flashy.is.co.za>
Message-ID: <Pine.LNX.3.96.980803190939.3185A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Craig Schlenter <craig@is.co.za>
Cc: "Jon M. Taylor" <taylorj@ecs.csus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 1998, Craig Schlenter wrote:
> On Sun, 2 Aug 1998, Rik van Riel wrote:
> 
> > It sure would be cool to have native S3trio support
> > from the kernel :)
> 
> Agreed. I asked this a week or two back. It seems as if the s3 stuff in
> the kernel is ppc specific (but maybe someone can tune it a little) and

According to Geert, the S3triofb driver needs the video
mode setup to by some other code;
According to Jon, the KGI S3 driver works without prior
setup stuff.

Maybe the KGI S3 setup code could be ported into the
S3triofb driver?    [preferably by someone with both
intimate knowledge of the video code and free time]

After that, the S3trio driver might still need some
endianness porting, but possibly that's just a minor
nuisance instead of real trouble.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
