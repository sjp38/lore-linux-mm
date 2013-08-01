Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B14BF6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 18:13:25 -0400 (EDT)
Message-ID: <51FADD6F.3040804@linux.intel.com>
Date: Thu, 01 Aug 2013 15:13:03 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] drivers: base: new memory config sysfs driver for large
 memory systems
References: <1374786680-26197-1-git-send-email-sjenning@linux.vnet.ibm.com> <20130725234007.GB18349@kroah.com> <20130726144251.GB4379@variantweb.net> <20130801205724.GA13585@kroah.com>
In-Reply-To: <20130801205724.GA13585@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Nivedita Singhvi <niv@us.ibm.com>, Michael J Wolf <mjwolf@us.ibm.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On 08/01/2013 01:57 PM, Greg Kroah-Hartman wrote:
>> > "memory" is the name used by the current sysfs memory layout code in
>> > drivers/base/memory.c. So it can't be the same unless we are going to
>> > create a toggle a boot time to select between the models, which is
>> > something I am looking to add if this code/design is acceptable to
>> > people.
> I know it can't be the same, but this is like "memory_v2" or something,
> right?  I suggest you make it an either/or option, given that you feel
> the existing layout just will not work properly for you.

If there are existing tools or applications that look for memory hotplug
events, how does this interact with those?  I know you guys have control
over the ppc software that actually performs the probe/online
operations, but what about other apps?

I also don't seem to see the original post to LKML.  Did you send
privately to Greg, then he cc'd LKML on his reply?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
