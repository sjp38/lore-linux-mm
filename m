Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 3FD566B02AA
	for <linux-mm@kvack.org>; Thu,  2 May 2013 23:03:52 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Thu, 2 May 2013 21:03:51 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1F42E38C8042
	for <linux-mm@kvack.org>; Thu,  2 May 2013 23:03:49 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4333miK256320
	for <linux-mm@kvack.org>; Thu, 2 May 2013 23:03:49 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4333mfv032022
	for <linux-mm@kvack.org>; Thu, 2 May 2013 21:03:48 -0600
Date: Fri, 3 May 2013 11:03:45 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <20130503030345.GE4441@localhost.localdomain>
References: <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com>
 <20130425060705.GK2672@localhost.localdomain>
 <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
 <20130426062436.GB4441@localhost.localdomain>
 <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com>
 <20130427112418.GC4441@localhost.localdomain>
 <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com>
 <20130429145711.GC1172@dhcp22.suse.cz>
 <20130502105637.GD4441@localhost.localdomain>
 <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, May 02, 2013 at 03:10:15PM +0000, Christoph Lameter wrote:
> On Thu, 2 May 2013, Han Pingtian wrote:
> 
> > Looks like "ibmvscsi" + "slub" can trigger this problem.
> 
> And the next merge of the slab-next tree will also cause SLAB to trigger
> this issue. I would like to have this fixes. The slab allocator purpose is
> to servr objects that are a fraction of a page and not objects that are
> larger than the maximum allowed sizes of the page allocator.

So the problem is in memory management code, not in ibmvscis? And looks
like there is a fix already?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
