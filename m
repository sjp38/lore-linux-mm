Date: Wed, 27 Sep 2000 00:16:20 +0200
From: Marko Kreen <marko@l-t.ee>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
Message-ID: <20000927001620.A26488@l-t.ee>
References: <Pine.GSO.4.21.0009250101150.14096-100000@weyl.math.psu.edu> <Pine.GSO.4.21.0009261715320.22614-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.21.0009261715320.22614-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Tue, Sep 26, 2000 at 05:29:27PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 05:29:27PM -0400, Alexander Viro wrote:
> Comments and help in testing are more than welcome.

There is something fishy in ext2_empty_dir:

+                               /* check for . and .. */
+                               if (de->name[0] != '.')
+                                       goto not_empty;
+                               if (!de->name[1]) {
+                                       if (de->inode !=
+                                           le32_to_cpu(inode->i_ino))
+                                               goto not_empty;
+                               } else if (de->name[2])
+                                       goto not_empty;
+                               else if (de->name[1] != '.')
+                                       goto not_empty;


-- 
marko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
