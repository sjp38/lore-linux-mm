Date: Sun, 05 May 2002 19:55:48 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [RFC][PATCH] dcache and rmap
Message-ID: <4269984342.1020628547@[10.10.2.3]>
In-Reply-To: <200205052117.16268.tomlins@cam.org>
References: <200205052117.16268.tomlins@cam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I got tired of finding my box with 50-60% percent of memory tied 
> up in dentry/inode caches every morning after update-db runs or 
> after doing a find / -name "*" to generate a list of files for 
> backups.  So I decided to make a stab at fixing this.

Are you actually out of memory at this point, and they're consuming
space you really need?

> The issue then becomes when to call the new shrink_caches function?  
> I changed the dcache logic to estimate and track the number of new 
> pages alloced to dentries.  Once a threshold is exceeded, kswapd 
> calls shrink_caches.   Using a threshold of 32 pages works well 
> here.

Why would you want to shrink the cache if you had plenty of free 
memory? Maybe I'm mistunderstanding what you're trying to do,
but that's what your explanation sounds like ....

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
