Date: Sat, 6 May 2000 18:02:11 +0100
From: Steve Dodd <steved@loth.demon.co.uk>
Subject: Re: Updates to /bin/bash
Message-ID: <20000506180210.A6381@loth.demon.co.uk>
References: <852568D5.006DBD55.00@raylex-gh01.eo.ray.com> <39121254.F7F71DAC@directlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <39121254.F7F71DAC@directlink.net>; from Matthew Vanecek on Thu, May 04, 2000 at 07:14:12PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Vanecek <linuxguy@directlink.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[I don't seem to have the start of this thread..]

On Thu, May 04, 2000 at 07:14:12PM -0500, Matthew Vanecek wrote:

> Well, the executable is loaded into memory once started.  For the most
> part, you can overwrite the executable (or other file) on the disk, as
> long as you have permissions to do so. [..]

Err, no, the executable is paged in and out as required. Updating a running
executable simply means you must make sure to create a *different* inode
for the new version, instead of scribbling over the existing one, i.e.:

cp /mnt/foo/bar /bin/bar.new
rm /bin/bar
mv /bin/bar.new /bin/bar

When the last user of the old version goes away, the inode for it is deleted.
New users see the new version.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
