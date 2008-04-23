Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NJ4kHo021042
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 15:04:46 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NJ7H50191808
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 13:07:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NJ7H8D013515
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 13:07:17 -0600
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080423183252.GA10548@us.ibm.com>
References: <20080411234913.GH19078@us.ibm.com>
	 <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de>
	 <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com>
	 <20080417231617.GA18815@us.ibm.com>
	 <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
	 <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com>
	 <20080423010259.GA17572@wotan.suse.de>  <20080423183252.GA10548@us.ibm.com>
Content-Type: text/plain
Date: Wed, 23 Apr 2008 14:07:46 -0500
Message-Id: <1208977666.17385.113.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-04-23 at 11:32 -0700, Nishanth Aravamudan wrote:
> So, I think, we pretty much agree on how things should be:
> 
> Direct translation of the current sysctl:
> 
> /sys/kernel/hugepages/nr_hugepages
>                       nr_overcommit_hugepages
> 
> Adding multiple pools:
> 
> /sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
>                       nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${default_size}
>                       nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${other_size1}
>                       nr_overcommit_hugepages_${other_size2}
> 
> Adding per-node control:
> 
> /sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
>                       nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${default_size}
>                       nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${other_size1}
>                       nr_overcommit_hugepages_${other_size2}
>                       nodeX/nr_hugepages -> nr_hugepages_${default_size}
>                             nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
>                             nr_hugepages_${default_size}
>                             nr_overcommit_hugepages_${default_size}
>                             nr_hugepages_${other_size1}
>                             nr_overcommit_hugepages_${other_size2}
> 
> How does that look? Does anyone have any problems with such an
> arrangement?

This seems sensible to me.  

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
