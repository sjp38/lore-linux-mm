Content-Type: text/plain;
  charset="iso-8859-1"
From: Rene Herman <rene.herman@keyaccess.nl>
Subject: Re: VM trouble, both 2.4 and 2.5
Date: Sat, 16 Nov 2002 01:18:40 +0100
References: <02111521422000.00195@7ixe4> <3DD578D1.1E3134A0@digeo.com>
In-Reply-To: <3DD578D1.1E3134A0@digeo.com>
MIME-Version: 1.0
Message-Id: <02111601184000.00209@7ixe4>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, Con Kolivas <contest@kolivas.net>
List-ID: <linux-mm.kvack.org>

On Friday 15 November 2002 23:44, Andrew Morton wrote:

> Are you *sure* it happens with ext2?  Checked /proc/mounts to ensure
> that /tmp is really ext2?

Darn it!

You are absolutely correct, /tmp was on /, ext3 builtin, ext2 as module, so 
it was really still ext3. /bin/mount lied to me. When I moved /tmp to its own 
partition, really ext2 this time, things stopped misbehaving. That ext2/ext3 
thing was the very first thing I tried, wasted a lot of time :-(

> I could certainly believe that the (weird) ext3 behaviour would upset
> the overcommit beancounting though.  Hundreds of megabytes of memory
> on the inactive list but not in pagecache probably looks like anonymous
> memory to the overcommit logic.

Does this bit mean the report was still somewhat useful (for fixing either 
ext3 or the overcommit accounting) though, or was it already well-known?

Well, anyways, thanks heaps for the explanation, was going slowly mad here ...

Rene.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
