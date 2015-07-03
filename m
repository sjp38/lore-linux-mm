Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0A06428027F
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 15:49:19 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so81768057ieb.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 12:49:18 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id 81si9569733iop.43.2015.07.03.12.49.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 12:49:18 -0700 (PDT)
Received: by igrv9 with SMTP id v9so122304717igr.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 12:49:18 -0700 (PDT)
Message-ID: <5596E73B.8060101@gmail.com>
Date: Fri, 03 Jul 2015 15:49:15 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com> <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org> <55956204.2060006@gmail.com> <20150703144635.GE9456@thunk.org> <5596A20F.6010509@gmail.com> <20150703150117.GA3688@dhcp22.suse.cz> <5596A42F.60901@gmail.com> <20150703164944.GG9456@thunk.org> <5596BDB6.5060708@gmail.com> <20150703184501.GJ9456@thunk.org>
In-Reply-To: <20150703184501.GJ9456@thunk.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-03 02:45 PM, Theodore Ts'o wrote:
> On Fri, Jul 03, 2015 at 12:52:06PM -0400, nick wrote:
>> I agree with you 100 percent. The reason I can't test this is I don't have the
>> hardware otherwise I would have tested it by now.
> 
> Then don't send the patch out.  Work on some other piece of part of
> the kernel, or better yet, some other userspace code where testing is
> easier.  It's really quite simple.
> 
> You don't have the technical skills, or at this point, the reputation,
> to send patches without tesitng them first.  The fact that sometimes
> people like Linus will send out a patch labelled with "COMPLETELY
> UNTESTED", is because he's skilled and trusted enough that he can get
> away with it.  You have neither of those advantages.
> 
> Best regards,
> 
> 						- Ted
> 
Ted,
My system breaks due to the commit id 7202ab46f7392265c1ecbf03f600393bf32a8bdf on boot
as I get a hang and black screen. In addition I even attempted single user mode but this
still happens with this commit. I found this by running git bisect on my system for the 
last few hours and hope this is more useful them my trivial cleanup patches. 
Nick 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
