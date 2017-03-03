Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE9816B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 17:29:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 10so58212447pgb.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 14:29:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o6si11768138plh.59.2017.03.03.14.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 14:29:55 -0800 (PST)
Date: Fri, 3 Mar 2017 14:29:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] thp: fix MADV_DONTNEED vs clear soft dirty race
Message-Id: <20170303142954.f01bc26179d6e28a2c18da5f@linux-foundation.org>
In-Reply-To: <20170302151034.27829-5-kirill.shutemov@linux.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
	<20170302151034.27829-5-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  2 Mar 2017 18:10:34 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Yet another instance of the same race.
> 
> Fix is identical to change_huge_pmd().

Nit: someone who is reading this changelog a year from now will be
quite confused - how do they work out what the race was?

I'll add

: See "thp: fix MADV_DONTNEED vs. numa balancing race" for more details.

to the changelogs to help them a bit.

Also, it wasn't a great idea to start this series with a "Restructure
code in preparation for a fix".  If people later start hitting this
race, the fixes will be difficult to backport.  I'm OK with taking that
risk, but please do bear this in mind in the future.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
