Date: Mon, 3 Jul 2000 11:46:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH: Trying to get back IO performance (WIP)
Message-ID: <20000703114651.G2699@redhat.com>
References: <ytthfa8oyc8.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <ytthfa8oyc8.fsf@serpe.mitica>; from quintela@fi.udc.es on Mon, Jul 03, 2000 at 02:24:07AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: marcelo@conectiva.com.br, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Mon, Jul 03, 2000 at 02:24:07AM +0200, Juan J. Quintela wrote:

>         This patch is against test3-pre2.
> It gives here good performance in the first run, and very bad
> in the following ones of dbench 48.  I am hitting here problems with
> the locking scheme.  I get a lot of contention in __wait_on_supper.
> Almost all the dbench processes are waiting in:
> 
>            0xc013639c __wait_on_super+0x184 (0xc13f4c00)
>            0xc01523e5 ext2_alloc_block+0x21 (0xc4840c20, 0x12901d, 0xc7427ea0)

Known, and I did a patch for this ages ago.  It actually didn't make a
whole lot of difference.  The last version of the ext2 diffs I did for
this are included below.

--Stephen


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ext2-super-lock-2.2.8.diff"


--vkogqOf2sHV7VnPd--
