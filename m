MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14645.1518.740545.133390@charged.uio.no>
Date: Wed, 31 May 2000 14:30:38 +0200 (CEST)
Subject: Re: PATCH: Rewrite of truncate_inode_pages (WIP)
In-Reply-To: <ytt7lcaex4g.fsf@serpe.mitica>
References: <yttvgzwg70s.fsf@serpe.mitica>
	<shsd7m3w0xp.fsf@charged.uio.no>
	<ytt7lcaex4g.fsf@serpe.mitica>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > OK, the problem here is that __remove_inode_pages needs to be
     > called with page->buffers==NULL.  What do you suggest to obtain
     > that?

     > Ok, tell me *the* correct way of doing that.  We need to make
     > sere that __remove_inode_page is called with page->buffers ==
     > NULL.  It is ok for you:
     >    if(page->buffers)
     >         BUG();

That's good. It won't affect NFS or smbfs, and it will catch any block 
devices that try to use that function.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
