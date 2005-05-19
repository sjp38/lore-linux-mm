Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4J1bIbM010813
	for <linux-mm@kvack.org>; Wed, 18 May 2005 21:37:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4J1bHPE134480
	for <linux-mm@kvack.org>; Wed, 18 May 2005 21:37:17 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4J1bHTc027662
	for <linux-mm@kvack.org>; Wed, 18 May 2005 21:37:17 -0400
Subject: Re: page flags ?
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1116461369.26913.1339.camel@dyn318077bld.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518145644.717afc21.akpm@osdl.org>
	 <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518162302.13a13356.akpm@osdl.org>
	 <1116461369.26913.1339.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: text/plain
Date: Wed, 18 May 2005 18:36:57 -0700
Message-Id: <1116466617.26955.115.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-18 at 17:09 -0700, Badari Pulavarty wrote:
> On Wed, 2005-05-18 at 16:23, Andrew Morton wrote:
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > >
> > > Is it possible to get yet another PG_fs_specific flag ? 
> > 
> > Anything's possible ;)
> > 
> > How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.
> 
> Depends on whom you ask :) CKRM folks are using one/few, 
> Hotplug memory guys are using one... :( I lost track..

Don't worry about me :)  There are a billion different ways to do what I
currently need that bit for.  It's just the easiest, and I'll code
something up that doesn't steal space from everyone else before I submit
it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
