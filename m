Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 290796B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:21:22 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6KJBtfb031849
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:11:55 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6KJLMaJ089780
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:21:24 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6KJLLhr018215
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:21:22 -0600
Subject: Re: [PATCH 4/8] v3 Allow memory_block to span multiple memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C451E1C.8070907@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	 <4C451E1C.8070907@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 20 Jul 2010 12:21:20 -0700
Message-ID: <1279653680.9785.5.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-07-19 at 22:55 -0500, Nathan Fontenot wrote:
> +static u32 get_memory_block_size(void)
> +{
> +       u32 block_sz;
> +
> +       block_sz = memory_block_size_bytes();
> +
> +       /* Validate blk_sz is a power of 2 and not less than section size */
> +       if ((block_sz & (block_sz - 1)) || (block_sz < MIN_MEMORY_BLOCK_SIZE))
> +               block_sz = MIN_MEMORY_BLOCK_SIZE;

Is this worth a WARN_ON()?  Seems pretty bogus if someone is returning
funky block sizes.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
