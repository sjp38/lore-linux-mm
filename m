Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4ILVoua036226
	for <linux-mm@kvack.org>; Wed, 18 May 2005 17:31:50 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4ILVo1o144348
	for <linux-mm@kvack.org>; Wed, 18 May 2005 15:31:50 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4ILVoGe017569
	for <linux-mm@kvack.org>; Wed, 18 May 2005 15:31:50 -0600
Subject: page flags ?
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Message-Id: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 18 May 2005 14:13:57 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Does anyone know what this page-flag is used for ? I see some
references to this in AFS. 

Is it possible for me to use this for my own use in ext3 ? 
(like delayed allocations ?) Any generic routines/VM stuff
expects me to use this only for a specific purpose ?

#define PG_fs_misc               9      /* Filesystem specific bit */

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
