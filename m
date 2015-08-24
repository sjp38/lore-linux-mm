Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E557F6B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:52:34 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so15502288pab.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:52:34 -0700 (PDT)
Received: from smtpbg63.qq.com (smtpbg63.qq.com. [103.7.29.150])
        by mx.google.com with ESMTPS id wy5si29602773pac.14.2015.08.24.14.52.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 14:52:34 -0700 (PDT)
Message-ID: <55DB9278.2020603@qq.com>
Date: Tue, 25 Aug 2015 05:54:00 +0800
From: Chen Gang <gang.chen.5i5j@qq.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com> <20150824113212.GL17078@dhcp22.suse.cz> <55DB1D94.3050404@hotmail.com> <COL130-W527FEAA0BEC780957B6B18B9620@phx.gbl> <20150824135716.GO17078@dhcp22.suse.cz>
In-Reply-To: <20150824135716.GO17078@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "gang.chen.5i5j@gmail.com" <gang.chen.5i5j@gmail.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 8/24/15 21:57, Michal Hocko wrote:
> On Mon 24-08-15 21:34:25, Chen Gang wrote:

[...]


>> It is always a little better to let the external function suppose fewer
>> callers' behalf.
> 
> I am sorry but I do not understand what you are saying here.
> 

Execuse me, my English maybe be still not quite well, my meaning is:

 - For the external functions (e.g. insert_vm_struct in our case), as a
   callee, it may have to supose something from the caller.

 - If we can keep callee's functional contents no touch, a little fewer
   supposing will let callee a little more independent from caller.

 - If can keep functional contens no touch, the lower dependency between
   caller and callee is always better.


>> It can save the code readers' (especially new readers') time resource
>> to avoid to analyze why set 'vma->vm_pgoff' before checking '-ENOMEM'
>> (may it cause issue? or is 'vm_pgoff' related with the next checking?).
> 
> Then your changelog should be specific about these reasons. "not a good
> idea" is definitely not a good justification for a patch. I am not
> saying the patch is incorrect I just do not sure it is worth it. The
> code is marginally better. But others might think otherwise. The
> changelog needs some more work for sure.
> 

OK, thanks. The comments needs to be improved.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
