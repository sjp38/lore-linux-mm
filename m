Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 714FE6B003B
	for <linux-mm@kvack.org>; Thu,  9 May 2013 18:18:50 -0400 (EDT)
Message-ID: <518C20C8.3010403@sr71.net>
Date: Thu, 09 May 2013 15:18:48 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/7] create __remove_mapping_batch()
References: <20130507211954.9815F9D1@viggo.jf.intel.com> <20130507212001.49F5E197@viggo.jf.intel.com> <20130509221327.GB14840@cerebellum>
In-Reply-To: <20130509221327.GB14840@cerebellum>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 05/09/2013 03:13 PM, Seth Jennings wrote:
>> > +	mapping = lru_to_page(remove_list)->mapping;
> This doesn't work for pages in the swap cache as mapping is overloaded to
> hold... something else that I can't remember of the top of my head.  Anyway,
> this happens:

Yup, that's true.  I'm supposed to be using page_mapping() here.  I know
I ran in to that along the way and fixed a few of the sites in my patch,
but missed that one.  I'll fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
