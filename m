Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0B31A6B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 20:29:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 10:17:42 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 589143578051
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:29:03 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3D0FB5h62914728
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:15:12 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3D0SVu0027923
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:28:31 +1000
Date: Sat, 13 Apr 2013 08:28:29 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH PART2 v2 2/7] staging: ramster: Move debugfs code out of
 ramster.c file
Message-ID: <20130413002829.GA17996@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365730287-16876-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130412221603.GA11282@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130412221603.GA11282@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Fri, Apr 12, 2013 at 03:16:03PM -0700, Greg Kroah-Hartman wrote:
>On Fri, Apr 12, 2013 at 09:31:22AM +0800, Wanpeng Li wrote:
>> Note that at this point there is no CONFIG_RAMSTER_DEBUG
>> option in the Kconfig. So in effect all of the counters
>> are nop until that option gets re-introduced in:
>> zcache/ramster/debug: Add RAMSTE_DEBUG Kconfig entry
>
>RAMSTE_DEBUG?  :)

I will update to CONFIG_RAMSTER_DEBUG. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
