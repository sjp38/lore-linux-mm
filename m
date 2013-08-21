Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id CF1076B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 14:50:52 -0400 (EDT)
Date: Wed, 21 Aug 2013 11:50:51 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/7] drivers: base: move mutex lock out of
 add_memory_section()
Message-ID: <20130821185051.GA11574@kroah.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130820172445.GE4151@medulla.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130820172445.GE4151@medulla.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, Aug 20, 2013 at 12:24:45PM -0500, Seth Jennings wrote:
> Gah! Forgot the cover letter.

No worries, I barely read them anyway :)

> This patchset just seeks to clean up and refactor some things in
> memory.c for better understanding and possibly better performance due do
> a decrease in mutex acquisitions and refcount churn at boot time.  No
> functional change is intended by this set!

All looks good, thanks for breaking it up into reviewable patches.  Now
applied.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
