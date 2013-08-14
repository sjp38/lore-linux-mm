Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id AB9A86B0034
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:37:25 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 14 Aug 2013 15:37:24 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DD9C13E40044
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:36:58 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7ELbLXu033796
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:37:21 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7ELbJWD007940
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:37:20 -0600
Message-ID: <520BF88C.6060202@linux.vnet.ibm.com>
Date: Wed, 14 Aug 2013 14:37:16 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com> <520BECDF.8060501@sr71.net> <20130814211454.GA17423@variantweb.net>
In-Reply-To: <20130814211454.GA17423@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dave Hansen <dave@sr71.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2013 02:14 PM, Seth Jennings wrote:
>> >An existing tool would not work
>> >with this patch (plus boot option) since it would not know how to
>> >show/hide things.  It lets_part_  of those existing tools get reused
>> >since they only have to be taught how to show/hide things.
>> >
>> >I'd find this really intriguing if you found a way to keep even the old
>> >tools working.  Instead of having an explicit show/hide, why couldn't
>> >you just create the entries on open(), for instance?
> Nathan and I talked about this and I'm not sure if sysfs would support
> such a thing, i.e. memory block creation when someone tried to cd into
> the memory block device config.  I wouldn't know where to start on that.
>

Also, I'd expect userspace tools might use readdir() to find out what 
memory blocks a system has (unless they just stat("memory0"), 
stat("memory1")...). I don't think filesystem tricks (at least within 
sysfs) are going to let this magically be solved without breaking the 
userspace API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
