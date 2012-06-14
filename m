Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 5E1AE6B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 23:20:16 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2277512dak.14
        for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:20:15 -0700 (PDT)
Date: Thu, 14 Jun 2012 12:20:05 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1339623535.3321.4.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339623535.3321.4.camel@lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 13, 2012 at 11:38:55PM +0200, Sasha Levin wrote:
> Hi all,
> 
> I'm seeing the following when booting a KVM guest with 65gb of RAM, on latest linux-next.
> 
> Note that it happens with numa=off.
> 
> [    0.000000] BUG: unable to handle kernel paging request at ffff88102febd948
> [    0.000000] IP: [<ffffffff836a6f37>] __next_free_mem_range+0x9b/0x155

Can you map it back to the source line please?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
