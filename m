Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3266C6B0027
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 19:50:48 -0400 (EDT)
Received: by mail-ia0-f172.google.com with SMTP id k38so936085iah.31
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 16:50:47 -0700 (PDT)
Message-ID: <516DE3D1.7030800@gmail.com>
Date: Wed, 17 Apr 2013 07:50:41 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
References: <5114DF05.7070702@mellanox.com> <CAH3drwbjQa2Xms30b8J_oEUw7Eikcno-7Xqf=7=da3LHWXvkKA@mail.gmail.com> <516CF7BB.3050301@gmail.com> <CAH3drwbx1aiQEA19+zq6t=GPPNZQEkD27sCjL-Ma2aYns7pMXw@mail.gmail.com>
In-Reply-To: <CAH3drwbx1aiQEA19+zq6t=GPPNZQEkD27sCjL-Ma2aYns7pMXw@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

On 04/17/2013 12:27 AM, Jerome Glisse wrote:

[snip]
>
>
> As i said this is for pre-filling already present entry, ie pte that 
> are present with a valid page (no special bit set). This is an 
> optimization so that the GPU can pre-fill its tlb without having to 
> take any mmap_sem. Hope is that in most common case this will be 
> enough, but in some case you will have to go through the lengthy non 
> fast gup.

I know this. What I concern is the pte you mentioned is for normal cpu, 
correct? How can you pre-fill pte and tlb of GPU?

>
> Cheers,
> Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
