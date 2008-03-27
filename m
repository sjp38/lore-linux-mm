Message-ID: <47EB8CED.60002@qumranet.com>
Date: Thu, 27 Mar 2008 14:02:53 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 00/15 v3] kvm on big iron
References: <1206030270.6690.51.camel@cotte.boeblingen.de.ibm.com>	 <1206205354.7177.82.camel@cotte.boeblingen.de.ibm.com> <1206467227.6507.36.camel@cotte.boeblingen.de.ibm.com>
In-Reply-To: <1206467227.6507.36.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, os@de.ibm.com, borntraeger@de.ibm.com, hollisb@us.ibm.com, EHRHARDT@de.ibm.com, jeroney@us.ibm.com, aliguori@us.ibm.com, jblunck@suse.de, rvdheij@gmail.com, rusty@rustcorp.com.au, arnd@arndb.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>, oliver.paukstadt@millenux.com
List-ID: <linux-mm.kvack.org>

Carsten Otte wrote:
> Many thanks for the review feedback we have received so far,
> and many thanks to Andrew for reviewing our common code memory
> management changes. I do greatly appreciate that :-).
>
> All important parts have been reviewed, all review feedback has been
> integrated in the code. Therefore we would like to ask for inclusion of
> our work into kvm.git.
>
> Changes from Version 1:
> - include feedback from Randy Dunlap on the documentation
> - include feedback from Jeremy Fitzhardinge, the prototype for dup_mm
>   has moved to include/linux/sched.h
> - rebase to current kvm.git hash g361be34. Thank you Avi for pulling
>   in the fix we need, and for moving KVM_MAX_VCPUS to include/arch :-).
>
> Changes from Version 2:
> - include feedback from Rusty Russell on the virtio patch
> - include fix for race s390_enable_sie() versus ptrace spotted by Dave 
>   Hansen: we now do task_lock() to protect mm_users from update while 
>   we're growing the page table. Good catch, Dave :-).
> - rebase to current kvm.git hash g680615e
>
>   

Applied all, thanks.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
