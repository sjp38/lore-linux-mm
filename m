Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 854D06B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 15:51:56 -0400 (EDT)
From: james_p_freyensee@linux.intel.com
Subject: kmalloc_slab() buffer underflow fix
Date: Thu, 19 May 2011 12:51:51 -0700
Message-Id: <1305834712-27805-1-git-send-email-james_p_freyensee@linux.intel.com>
In-Reply-To: <james_p_freyensee@linux.intel.com>
References: <james_p_freyensee@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: gregkh@suse.de, hari.k.kanigeri@intel.com, james_p_freyensee@linux.intel.com

In file slub_def.h I noticed the potential of kmalloc_caches[]
receiving a -1 in it's index in the function kmalloc_slab(),
which to me looks like a bad thing. Thus I wanted to send a 
patch to fix this.

>From james_p_freyensee@linux.intel.com # This line is ignored.
From: james_p_freyensee@linux.intel.com
Subject: kmalloc_slab() buffer underflow fix
In-Reply-To: james_p_freyensee@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
