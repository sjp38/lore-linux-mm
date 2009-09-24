Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 44EEA6B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 21:07:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O17QkY000869
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 10:07:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E919945DE5D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:07:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BCC845DE55
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:07:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 65527E78002
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:07:25 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C80E1DB803B
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:07:25 +0900 (JST)
Date: Thu, 24 Sep 2009 10:05:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4AB9A0D6.1090004@crca.org.au>
References: <4AB9A0D6.1090004@crca.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Sep 2009 14:15:18 +1000
Nigel Cunningham <ncunningham@crca.org.au> wrote:

> Hi all.
> 
> With the addition of the VM_MERGEABLE flag to vm_flags post-2.6.31, the
> last bit in vm_flags has been used.
> 

Wow...that's bad.



> I have some code in TuxOnIce that needs a bit too (explicitly mark the
> VMA as needing to be atomically copied, for GEM objects), and am not
> sure what the canonical way to proceed is. Should a new unsigned long be
> added? The difficulty I see with that is that my flag was used in
> shmem_file_setup's flags parameter (drm_gem_object_alloc), so that
> function would need an extra parameter too..
> 

Hmm, how about adding vma->vm_flags2 ?

Thanks,
-Kame


> Regards,
> 
> Nigel
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
