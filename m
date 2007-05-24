From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
Date: Thu, 24 May 2007 22:41:35 +0200
References: <20070524172821.13933.80093.sendpatchset@localhost>
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705242241.35373.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> 
> Basic "problem":  currently [~2.6.21], files mmap()ed SHARED
> do not follow mem policy applied to the mapped regions.  Instead, 
> shared, file backed pages are allocated using the allocating
> tasks' task policy.  This is inconsistent with the way that anon
> and shmem pages are handled, violating, for me, the Principle
> of Least Astonishment.

Do you have some specific use cases? Did this actually improve
some application significantly? 

The main basic issue is that it seems weird semantics to have the policy randomly
disappear when everybody closes the file depending on whether the system
decides to flush the inode or not. But using EAs or similar
also looked like overkill.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
