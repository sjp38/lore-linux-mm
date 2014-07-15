Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0476B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:44:45 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so4521068wib.8
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:44:44 -0700 (PDT)
Received: from unimail.uni-dortmund.de (mx1.HRZ.Uni-Dortmund.DE. [129.217.128.51])
        by mx.google.com with ESMTP id om6si20382708wjc.30.2014.07.15.08.44.41
        for <linux-mm@kvack.org>;
        Tue, 15 Jul 2014 08:44:43 -0700 (PDT)
Message-ID: <ec017fca7d5ebeaa35b3bd94e494683f.squirrel@webmail.tu-dortmund.de>
In-Reply-To: <20140715115832.18997.90349.stgit@buzz>
References: 
    <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
    <20140715115832.18997.90349.stgit@buzz>
Date: Tue, 15 Jul 2014 17:29:06 +0200
Subject: Re: [PATCH] mm: do not call do_fault_around for non-linear fault
From: "Ingo Korb" <ingo.korb@tu-dortmund.de>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ning Qu <quning@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

> Faulting around non-linear page-fault has no sense and
> breaks logic in do_fault_around because pgoff is shifted.

I can confirm that this patches fixes the bug here not just for the test
program but also the application where I originally noticed it.

-ik


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
