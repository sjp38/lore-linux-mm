Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.59-mm5
Date: Sat, 25 Jan 2003 15:34:32 -0500
References: <20030123195044.47c51d39.akpm@digeo.com> <200301251232.15866.tomlins@cam.org> <20030125094141.1e2b1de3.akpm@digeo.com>
In-Reply-To: <20030125094141.1e2b1de3.akpm@digeo.com>
MIME-Version: 1.0
Message-Id: <200301251534.32447.tomlins@cam.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On January 25, 2003 12:41 pm, Andrew Morton wrote:
> Ed Tomlinson <tomlins@cam.org> wrote:
> > Hi Andrew,
> >
> > I am seeing a strange problem with mm5.  This occurs both with and
> > without the anticipatory scheduler changes.  What happens is I see very
> > high system times and X responds very very slowly.  I first noticed this
> > when switching between folders in kmail and have seen it rebuilding db
> > files for squidguard. Here is what happened during the db rebuild (no
> > anticipatory ioscheduler):
>
> Could you please try reverting the reiserfs changes?
>
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-out/
>reiserfs-readpages.patch
>
> and
>
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-out/
>reiserfs_file_write.patch

Reverting reiserfs_file_write.patch seems to cure the interactivity problems.
I still see the high system times but they in themselves are not a problem.
Reverting the second patch does not change the situation.  I am currently
running with reiserfs_file_write.patch removed - so far so good.

Thanks
Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
