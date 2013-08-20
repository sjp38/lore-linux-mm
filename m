Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3272D6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:24:47 -0400 (EDT)
Date: Tue, 20 Aug 2013 12:24:45 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/7] drivers: base: move mutex lock out of
 add_memory_section()
Message-ID: <20130820172445.GE4151@medulla.variantweb.net>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Gah! Forgot the cover letter.

This patchset just seeks to clean up and refactor some things in
memory.c for better understanding and possibly better performance due do
a decrease in mutex acquisitions and refcount churn at boot time.  No
functional change is intended by this set!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
