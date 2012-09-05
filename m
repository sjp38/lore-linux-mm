Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0B5226B0069
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:10:01 -0400 (EDT)
Message-ID: <5047161F.60503@parallels.com>
Date: Wed, 5 Sep 2012 13:06:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <1346768300-10282-1-git-send-email-glommer@parallels.com> <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com> <5047074D.1030104@parallels.com> <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470A87.1040701@parallels.com> <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470EBF.9070109@parallels.com> <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com> <50471379.3060603@parallels.com> <20120905090744.GG3195@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120905090744.GG3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On 09/05/2012 01:07 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Sep 05, 2012 at 12:55:21PM +0400, Glauber Costa wrote:
>>> So, I think it's desirable for all controllers to be able to handle
>>> hierarchies the same way and to have the ability to tag something as
>>> belonging to certain group in the hierarchy for all controllers but I
>>> don't think it's desirable or feasible to require all of them to
>>> follow exactly the same grouping at all levels.
>>
>> By "different levels of granularity" do you mean having just a subset of
>> them turned on at a particular place?
> 
> Heh, this is tricky to describe and I'm not really following what you
> mean. 

Do we really want to start cleaning up all this by changing the
interface to something that is described as "tricky" ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
