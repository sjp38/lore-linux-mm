Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA26813
	for <linux-mm@kvack.org>; Sat, 25 Jan 2003 09:41:06 -0800 (PST)
Date: Sat, 25 Jan 2003 09:41:41 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm5
Message-Id: <20030125094141.1e2b1de3.akpm@digeo.com>
In-Reply-To: <200301251232.15866.tomlins@cam.org>
References: <20030123195044.47c51d39.akpm@digeo.com>
	<m3lm1au51v.fsf@lexa.home.net>
	<20030124111249.227a40d6.akpm@digeo.com>
	<200301251232.15866.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> Hi Andrew,
> 
> I am seeing a strange problem with mm5.  This occurs both with and without
> the anticipatory scheduler changes.  What happens is I see very high system
> times and X responds very very slowly.  I first noticed this when switching
> between folders in kmail and have seen it rebuilding db files for squidguard.
> Here is what happened during the db rebuild (no anticipatory ioscheduler):

Could you please try reverting the reiserfs changes?

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-out/reiserfs-readpages.patch

and

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-out/reiserfs_file_write.patch


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
