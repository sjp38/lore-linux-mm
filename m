From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.68-mm2
Date: Wed, 23 Apr 2003 08:08:25 -0400
References: <20030423012046.0535e4fd.akpm@digeo.com>
In-Reply-To: <20030423012046.0535e4fd.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Message-Id: <200304230808.25387.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On April 23, 2003 04:20 am, Andrew Morton wrote:
> . I got tired of the objrmap code going BUG under stress, so it is now in
>   disgrace in the experimental/ directory.

As far as I see it there are two problems that objrmap/shpte/pgcl try to solve.
One is low memory pte useage, the second being to reduce the rmap fork overhead.

objrmap helps in both cases but has problem with truncate and intoduces a O(n^2)
search into the the vm.

shpte helps a lot with the first problem, and does not seem to do much for the
second.  If I remember correctly it could also be a config option.

pgcl should help with both to some extent but is not ready for prime time - yet.

>From comments recently made on lkml I believe that the first problem is probably 
more pressing.  What problems need to be resolved with each patch?   

Ed Tomlinson



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
