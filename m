Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [RFC][PATCH] dcache and rmap
Date: Mon, 6 May 2002 03:54:52 -0400
References: <200205052117.16268.tomlins@cam.org> <4269984342.1020628547@[10.10.2.3]>
In-Reply-To: <4269984342.1020628547@[10.10.2.3]>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205060354.52173.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 5, 2002 10:55 pm, Martin J. Bligh wrote:
> > I got tired of finding my box with 50-60% percent of memory tied
> > up in dentry/inode caches every morning after update-db runs or
> > after doing a find / -name "*" to generate a list of files for
> > backups.  So I decided to make a stab at fixing this.
>
> Are you actually out of memory at this point, and they're consuming
> space you really need?

Think of this another way.  There are 100000+ dentry/inodes in memory
comsuming 250M or so.  Meanwhile load is light and the background
aging is able to supply pages for the freelist.  We do not reclaim this
storage until we have vm pressure.  Usually this pressure is artifical, 
if we had reclaimed the storage it would not have occured, our caches
would have more useful data in them, and half the memory would not
sit idle for half a day.  

We age the rest of the memory to keep it hot.   Rmap does a good job 
and keeps the freelist heathly.  In this case nothing ages the dentries
and they get very cold.  My code ensures that the memory consumed 
by the, potentially cold, dentries/inodes is not excessive.

(I hate getting paged at 3 in the morning)

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
