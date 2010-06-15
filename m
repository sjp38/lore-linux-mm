Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B13496B01D7
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 03:52:21 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5F7msNs012058
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:48:54 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5F7qChS174772
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:52:12 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5F7qBOw032526
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:52:12 -0600
Date: Tue, 15 Jun 2010 13:22:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100615075210.GB4306@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100610142512.GB5191@balbir.in.ibm.com>
 <1276214852.6437.1427.camel@nimitz>
 <20100611045600.GE5191@balbir.in.ibm.com>
 <4C15E3C8.20407@redhat.com>
 <20100614084810.GT5191@balbir.in.ibm.com>
 <1276528376.6437.7176.camel@nimitz>
 <20100614165853.GW5191@balbir.in.ibm.com>
 <1276535371.6437.7417.camel@nimitz>
 <20100614171624.GY5191@balbir.in.ibm.com>
 <4C1727EC.2020500@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C1727EC.2020500@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-15 10:12:44]:

> On 06/14/2010 08:16 PM, Balbir Singh wrote:
> >* Dave Hansen<dave@linux.vnet.ibm.com>  [2010-06-14 10:09:31]:
> >
> >>On Mon, 2010-06-14 at 22:28 +0530, Balbir Singh wrote:
> >>>If you've got duplicate pages and you know
> >>>that they are duplicated and can be retrieved at a lower cost, why
> >>>wouldn't we go after them first?
> >>I agree with this in theory.  But, the guest lacks the information about
> >>what is truly duplicated and what the costs are for itself and/or the
> >>host to recreate it.  "Unmapped page cache" may be the best proxy that
> >>we have at the moment for "easy to recreate", but I think it's still too
> >>poor a match to make these patches useful.
> >>
> >That is why the policy (in the next set) will come from the host. As
> >to whether the data is truly duplicated, my experiments show up to 60%
> >of the page cache is duplicated.
> 
> Isn't that incredibly workload dependent?
> 
> We can't expect the host admin to know whether duplication will
> occur or not.
>

I was referring to cache = (policy) we use based on the setup. I don't
think the duplication is too workload specific. Moreover, we could use
aggressive policies and restrict page cache usage or do it selectively
on ballooning. We could also add other options to make the ballooning
option truly optional, so that the system management software decides. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
