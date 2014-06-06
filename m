Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 08A006B00B2
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 19:28:13 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so3068787pbb.35
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 16:28:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cc2si22069105pbc.255.2014.06.06.16.28.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 16:28:13 -0700 (PDT)
Message-ID: <53924D10.4050305@oracle.com>
Date: Fri, 06 Jun 2014 19:21:52 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: 3.15-rc8 mm/filemap.c:202 BUG
References: <20140603042121.GA27177@redhat.com>	<CALYGNiNV951SnBKdr0PEkgLbLCxy+YB6HJpafRr6CynO+a1sdQ@mail.gmail.com>	<alpine.LSU.2.11.1406031524470.7878@eggly.anvils>	<538F121E.9020100@oracle.com>	<alpine.LSU.2.11.1406061549500.9818@eggly.anvils> <CA+55aFy939whF-vo+GyOhkyqgOEUGqAt-cmAB2gSOFHKBeGCPA@mail.gmail.com>
In-Reply-To: <CA+55aFy939whF-vo+GyOhkyqgOEUGqAt-cmAB2gSOFHKBeGCPA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 06/06/2014 07:16 PM, Linus Torvalds wrote:
>> I have no evidence that its lack is responsible for the mm/filemap.c:202
>> > BUG_ON(page_mapped(page)) in __delete_from_page_cache() found by trinity,
>> > and I am not optimistic that it will fix it.  But I have found no other
>> > explanation, and ACCESS_ONCE() here will surely not hurt.
> The patch looks obviously correct to me, although like you, I have no
> real reason to believe it really fixes anything. But we definitely
> should just load it once, since it's very much an optimistic load done
> before we take the real lock and re-compare.
> 
> I'm somewhat dubious whether it actually would change code generation
> - it doesn't change anything with the test-configuration I tried with
> - but it's unquestionably a good patch. And hey, maybe some
> configurations have sufficiently different code generation that gcc
> actually _can_ sometimes do reloads, perhaps explaining why some
> people see problems. So it's certainly worth testing even if it
> doesn't make any change to code generation with *my* compiler and
> config..

I'm seeing the same code generated here as well. I won't carry the
patch unless Andrew/Linus take it so it won't hide possible bugs that
trinity might stumble on.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
