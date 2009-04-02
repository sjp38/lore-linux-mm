Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 718766B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 11:20:35 -0400 (EDT)
Date: Thu, 2 Apr 2009 08:20:45 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 5/4] update ksm userspace interfaces
Message-ID: <20090402152045.GB10392@x200.localdomain>
References: <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws> <20090402053114.GF1117@x200.localdomain> <49D4BE64.8020508@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D4BE64.8020508@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Chris Wright <chrisw@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

* Izik Eidus (ieidus@redhat.com) wrote:
> So if we move into madvice and we remove the get_task_mm() usage, we  
> will have to add notification to exit_mm() so ksm will know it should  
> stop using this mm strcture, and drop it from all the trees data...

Technically it's needed already.  This example is currently semi-broken:

main()
 ksm_register_memory
 execve()   <-- no notifiction unless fd is proactively marked cloexec
                (which it isn't)

   new proc...do stuff (it's ->mm isn't registered)
   eventually exit() <-- close fd and clear up the old stale ->mm registered

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
