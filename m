Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 74E026B0087
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:51:53 -0400 (EDT)
Message-ID: <50471FEE.8060408@parallels.com>
Date: Wed, 5 Sep 2012 13:48:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470A87.1040701@parallels.com> <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470EBF.9070109@parallels.com> <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com> <1346835993.2600.9.camel@twins> <20120905091140.GH3195@dhcp-172-17-108-109.mtv.corp.google.com> <50471782.6060800@parallels.com> <1346837209.2600.14.camel@twins> <50471C0C.7050600@parallels.com> <20120905094520.GM3195@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120905094520.GM3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On 09/05/2012 01:45 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Sep 05, 2012 at 01:31:56PM +0400, Glauber Costa wrote:
>>> > > I simply don't want to have to do two (or more) hierarchy walks for
>>> > > accounting on every schedule event, all that pointer chasing is stupidly
>>> > > expensive.
>> > 
>> > You wouldn't have to do more than one hierarchy walks for that. What
>> > Tejun seems to want, is the ability to not have a particular controller
>> > at some point in the tree. But if they exist, they are always together.
> Nope, as I wrote in the other reply, 

Would you mind, then, stopping for a moment and telling us what it is,
then, that you envision?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
