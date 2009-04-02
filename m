Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A5BB56B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 12:00:47 -0400 (EDT)
Message-ID: <49D4E00B.8050904@redhat.com>
Date: Thu, 02 Apr 2009 18:55:55 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/4] update ksm userspace interfaces
References: <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws> <20090402053114.GF1117@x200.localdomain> <49D4BE64.8020508@redhat.com> <20090402155633.GD10392@x200.localdomain>
In-Reply-To: <20090402155633.GD10392@x200.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Chris Wright wrote:
> * Izik Eidus (ieidus@redhat.com) wrote:
>   
>> Is this what we want?
>>     
>
> How about baby steps...
>
> admit that ioctl to control plane is better done via sysfs?
>   
Yes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
